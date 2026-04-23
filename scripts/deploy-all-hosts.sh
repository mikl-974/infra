#!/usr/bin/env bash
set -euo pipefail

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/workstation-install.sh
source "$_SCRIPT_DIR/lib/workstation-install.sh"
REPO_ROOT="$(resolve_repo_root "$_SCRIPT_DIR")"

# Apply every NixOS host configuration declared in deployments/colmena.nix.
# Hosts not present in the Colmena hive (e.g. workstations) are not touched.
exec colmena apply --config "$REPO_ROOT/deployments/colmena.nix"
