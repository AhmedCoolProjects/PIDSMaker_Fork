#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
set -a
source "$SCRIPT_DIR/../.env.local"
set +a

PIDSMAKEROPS_ROOT="/srv/lustre01/project/data_sec-um6p-st-sccs-6sevvl76uja/IDS/ahmed.bargady/work/pidsmakerops"
PYTHON="/home/ahmed.bargady/.conda/envs/p_starter/bin/python"

cd "$PIDSMAKEROPS_ROOT"
export LD_LIBRARY_PATH="/home/ahmed.bargady/.conda/envs/p_starter/lib:${LD_LIBRARY_PATH:-}"
export PYTHONPATH="$PIDSMAKEROPS_ROOT:${PYTHONPATH:-}"
export PYTHONHASHSEED=0

"$PYTHON" -u pidsmaker/main.py velox CADETS_E3 \
  --wandb \
  --exp=velox_pidsmakerops_repro \
  --group=velox_pidsmakerops_repro \
  --cpu \
  --database_host 10.43.1.3 \
  --database_port 5433 \
  --database_user postgres \
  --database_password "" \
  --artifact_dir /home/ahmed.bargady/lustre/jepa-qdy1am7soje/users/ahmed.bargady/pids/artifacts/pidsmakerops_repro \
  --training.encoder.dropout=0.3 \
  --batching.intra_graph_batching.used_methods=edges \
  --training.lr=0.0001 \
  --training.node_hid_dim=256 \
  --training.node_out_dim=256 \
  --training.num_epochs=12 \
  --featurization.emb_dim=256 \
  --training.seed=1
