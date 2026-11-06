# Velox on CADETS-E3 — Reproduction Notes (Issue #26 Hyperparameters)

## 1. Tested Configuration (from [PIDSMaker Issue #26](https://github.com/ubc-provenance/PIDSMaker/issues/26) & `docs/docs/tuned_systems.md`)

Note: CLI argument prefixes were renamed in commit `0a67dab` (`detection.gnn_training.*` $\rightarrow$ `training.*`, `featurization.feat_training.*` $\rightarrow$ `featurization.*`).

```bash
python pidsmaker/main.py velox CADETS_E3 \
  --training.encoder.dropout=0.3 \
  --training.lr=0.0001 \
  --training.node_hid_dim=256 \
  --training.node_out_dim=256 \
  --training.num_epochs=12 \
  --featurization.emb_dim=256
```

## 2. Observed Result vs. USENIX Security '25 Paper Claim

| Source | ADP | Precision | Recall | F1 | TP | FP | FN | TN | AUC | AP |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Paper Claim (Table 3, Best)** | `1.000` (mean `0.94`) | `1.000` (mean `0.85`) | `0.118` (8/68) | `0.211` | `8` | `0` | `60` | — | — | — |
| **Run 1: Issue #26 Params (Best Epoch 9)** | `0.007` | `0.000` | `0.000` | `0.000` | `0` | `120` | `68` | `281397` | `0.77287` | `0.00144` |
| **Run 2: `usenixsec` Tag Params (Best Epoch 1)** | `0.012` | `0.000` | `0.000` | `0.000` | `0` | `26` | `68` | `281491` | `0.76931` | `0.00207` |

*Note on Run 2 (`emb_dim=64, seed=2, lr=0.001, node_hid_dim=128, node_out_dim=256, num_epochs=8`):*
- False positives dropped from `120` to `26` (`FPR = 0.0000924`), `precision@50 = 0.02`, and top malicious node (`nid=370876`, `sshd` in Attack 2) rose to **rank 45 / 281,585** (`score = 24.2086` vs. `threshold = 24.9081`, missing threshold by `0.70`). By Epoch 7, `AUC` reached `0.84458` (`TP = 10, FP = 2772`), but `ADP` remained `0.004–0.012`.

## 3. Root Causes Identified (Code Drift Between `usenixsec` Tag and Current `HEAD`)

Inspecting `git show usenixsec:...` against current `HEAD` (`v3.0.0`) shows that **Velox's forward pass and batching in the current repo no longer match the `usenixsec` release**:

1. **`GraphReindexer` double-scatter corruption (`x_is_tuple: False` in `HEAD` vs. edge-tuple `(x_src, x_dst)` in `usenixsec`):**
   - In `usenixsec:src/model.py:92-97`, `_reshape_x(batch)` returned `x = (batch.x_src, batch.x_dst)` of shape `(E, d)` whenever `self.node_level` was `False`, bypassing `GraphReindexer`'s node feature scatter completely.
   - In current `HEAD` (`pidsmaker/utils/data_utils.py:845-848`), `x_is_tuple` is `False` (reverted in commit `0797215`) and `fix_buggy_graph_reindexer` is `False` (`config/orthrus.yml:39`). `GraphReindexer.node_features_reshape` executes:
     ```python
     scatter(x_src, edge_index[0], out=output, dim=0, reduce="mean")
     scatter(x_dst, edge_index[1], out=output, dim=0, reduce="mean")
     ```
     Because `output` is **not zeroed** between the two `scatter` calls, any node that appears as both a source and a destination in the same batch has its `x_dst` mean **added onto** its `x_src` mean (doubling its feature vector magnitude $2\times$), while source-only or destination-only nodes remain at $1\times$.

2. **`intra_graph_batching: edges` (1024-edge sub-batches) added after `usenixsec`:**
   - In `usenixsec:src/factory.py:300-310`, `use_tgn` was `False` for Velox, so `batch_loader_factory` trained on full 15-minute time-window graphs (`return [data]`, 1 optimizer step per time window).
   - Commit `e91f43e` added `batching.intra_graph_batching.used_methods: edges` (`1024` edges per sub-batch) to `config/velox.yml`, increasing optimizer steps per epoch by ~20x and changing which nodes co-occur as both `src` and `dst` in each batch.

3. **`LinearEncoder` dropout added after `usenixsec`:**
   - In `usenixsec:src/encoders.py`, `LinearEncoder` was a pure `nn.Linear(in_dim, out_dim)` with **no dropout**. Current `pidsmaker/encoders/linear_encoder.py` applies `nn.Dropout(0.3)` after `self.lin1`.

4. **Anonymous `'file None'` nodes in `cadets_e3` dominating top false-positive scores:**
   - In `cadets_e3.file_node_table`, `2,260,767 / 2,303,164` file nodes (`98.16%`) have `path = None` (`label = 'file None'`).
   - In both Run 1 and Run 2, the highest-scoring test nodes (`score = 20.11` in Run 1, `score = 42.34` in Run 2) are identical benign edges between `['file', 'file None']` and `['subject', 'subject None sshd']` / `ntpd` / `syslogd`, which push the `max_val_loss` threshold above the top malicious nodes.
