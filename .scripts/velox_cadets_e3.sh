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

CMD=(
  /home/ahmed.bargady/.conda/envs/pids/bin/python -u pidsmaker/main.py velox CADETS_E3
  --wandb
  --cpu
  --database_host 10.43.1.3
  --database_port 5433
  --database_user postgres
  --database_password ""
  --artifact_dir /home/ahmed.bargady/lustre/jepa-qdy1am7soje/users/ahmed.bargady/pids/artifacts/pidsmaker
)

"${CMD[@]}" --training.seed=0
"${CMD[@]}" --training.seed=1
"${CMD[@]}" --training.seed=2
