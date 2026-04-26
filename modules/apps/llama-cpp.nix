{ pkgs, ... }:
let
  modelsDir = "/var/lib/llama-cpp/models";
in
{
  environment.systemPackages = with pkgs; [
    llama-cpp-rocm
    python3Packages.huggingface-hub
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/llama-cpp 2775 root render -"
    "d ${modelsDir} 2775 root render -"
  ];
}
