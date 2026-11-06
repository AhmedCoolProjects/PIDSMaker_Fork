#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/velox_cadets_e3.sh"
bash "$SCRIPT_DIR/velox_theia_e3.sh"
bash "$SCRIPT_DIR/velox_atlasv2_edr.sh"
bash "$SCRIPT_DIR/velox_optc.sh"
