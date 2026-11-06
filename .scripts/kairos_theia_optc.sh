#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# CADETS and ATLAS runs are completed.
bash "$SCRIPT_DIR/kairos_theia_e3.sh"
bash "$SCRIPT_DIR/kairos_optc.sh"
