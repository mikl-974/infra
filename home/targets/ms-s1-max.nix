# Home Manager composition for `ms-s1-max`.
#
# Single-user on purpose:
# - `mfo` only
# - Hyprland desktop
# - Noctalia shell
# - explicit browser/session overrides kept local to this target
{
  mfo = { lib, inputs, ... }: {
    imports = [
      ../users/mfo.nix
      inputs.mango.hmModules.mango
      ../roles/desktop-hyprland.nix
      ../roles/noctalia.nix
    ];

    wayland.windowManager.mango.enable = true;

    home.file.".config/hypr/profile.conf".source =
      lib.mkForce ../../dotfiles/hyprland/profiles/mfo.conf;

    home.sessionVariables.BROWSER = "chromium";
  };
}
