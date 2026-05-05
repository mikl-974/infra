# Empty Home Manager composition for the headless server `contabo`.
# sudo nixos-rebuild switch --flake /home/mfo/infra#contabo

# The host operator account (`admin`) is provisioned by
# `systems/users/admin.nix` at the system level; it has no Home Manager
# composition because there is no user-facing desktop on this target.
{ }
