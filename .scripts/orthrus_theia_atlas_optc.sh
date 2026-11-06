#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Theia and Atlas runs are already completed.
bash "$SCRIPT_DIR/orthrus_optc.sh"
