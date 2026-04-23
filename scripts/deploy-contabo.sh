#!/usr/bin/env bash
set -euo pipefail

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/workstation-install.sh
source "$_SCRIPT_DIR/lib/workstation-install.sh"
REPO_ROOT="$(resolve_repo_root "$_SCRIPT_DIR")"

# Apply the `contabo` NixOS host configuration via Colmena.
exec colmena apply --on contabo --config "$REPO_ROOT/deployments/colmena.nix"
