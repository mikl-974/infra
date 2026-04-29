{ ... }:
{
  imports = [
    ../apps/ollama-local.nix
    ../apps/llama-cpp.nix
    ../apps/opencode-desktop.nix
    ../apps/codex.nix
  ];

  services.flatpak.enable = true;
}
