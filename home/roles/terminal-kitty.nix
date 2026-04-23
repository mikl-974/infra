{ pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];

  home.file.".config/kitty/kitty.conf".source = ../../dotfiles/terminal/kitty.conf;
}
