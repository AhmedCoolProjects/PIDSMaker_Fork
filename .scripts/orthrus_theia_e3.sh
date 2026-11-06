#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SCRIPT_DIR")"
set -a
source "$ROOT/.env.local"
set +a
cd "$ROOT"
export LD_LIBRARY_PATH="/home/ahmed.bargady/.conda/envs/pids/lib:${LD_LIBRARY_PATH:-}"
export PYTHONPATH="$ROOT:${PYTHONPATH:-}"

exec /home/ahmed.bargady/.conda/envs/pids/bin/python -u pidsmaker/main.py orthrus_non_snooped THEIA_E3 \
  --wandb \
  --cpu \
  --database_host 10.43.1.3 \
  --database_port 5433 \
  --database_user postgres \
  --database_password "" \
  --artifact_dir /home/ahmed.bargady/lustre/jepa-qdy1am7soje/users/ahmed.bargady/pids/artifacts/pidsmaker \
  --training.seed=2
