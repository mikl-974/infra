#!/usr/bin/env bash
set -euo pipefail

# `tofu plan` for the `gcp-ext` cloud target workspace
# (deployments/topology.nix → kind = "gcpCloudRun").
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/workstation-install.sh
source "$_SCRIPT_DIR/lib/workstation-install.sh"
REPO_ROOT="$(resolve_repo_root "$_SCRIPT_DIR")"
cd "$REPO_ROOT/tofu/stacks/gcp-ext"
tofu init -input=false -upgrade
exec tofu plan
