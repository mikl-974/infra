#!/usr/bin/env bash
set -euo pipefail

# Strict validation of the deployments inventory against the topology and
# stack contracts. Exits non-zero (with the validation error list) if any
# rule from `deployments/validation.nix` is violated.
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/workstation-install.sh
source "$_SCRIPT_DIR/lib/workstation-install.sh"
REPO_ROOT="$(resolve_repo_root "$_SCRIPT_DIR")"
cd "$REPO_ROOT"

# Print human-readable summary on success; throw on failure.
nix-instantiate --eval --strict --json \
  -E 'let r = import ./deployments/validation.nix; in r.summaryText' \
  | sed -e 's/^"//' -e 's/"$//' -e 's/\\n/\n/g'

# Also force evaluation of the structured outputs so any silent regression on
# the topology/inventory/stacks tree is caught here too.
nix-instantiate --eval --strict --json \
  -E 'let r = import ./deployments/validation.nix; in { inherit (r) summary; }' \
  >/dev/null
