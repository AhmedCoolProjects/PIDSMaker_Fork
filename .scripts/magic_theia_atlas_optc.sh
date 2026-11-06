#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/magic_atlasv2_edr.sh"
bash "$SCRIPT_DIR/magic_theia_e3.sh"
bash "$SCRIPT_DIR/magic_optc.sh"
