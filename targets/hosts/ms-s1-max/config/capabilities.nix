{ lib, pkgs, ... }:
let
  llamaCppModel = "/var/lib/llama-cpp/models/qwen3.5-35b-a3b/Qwen_Qwen3.5-35B-A3B-Q4_K_M.gguf";
  llamaCppHost = "127.0.0.1";
  llamaCppPort = 8080;
in
{
  # Host-local capability map for `ms-s1-max`.
  #
  # This file is the authoritative place to answer:
  # "What does this machine have?"
  #
  # Keep the mapping explicit here even when it imports reusable bundles.
  imports = [
    ../../../../systems/containers/podman.nix
    ../../../../systems/bundles/dev-workstation.nix
    ../../../../systems/apps/podman-desktop.nix
    ../../../../systems/bundles/ai-local.nix
    ../../../../systems/bundles/gaming.nix
    ../../../../systems/bundles/rocm-runtime.nix
  ];

  # AnythingLLM is part of the intended workstation setup, but remains
  # installed through Flatpak until nixpkgs has a clean package for it:
  #   flatpak install flathub com.anythingllm.anythingllm

  nixpkgs.config.rocmSupport = true;

  # Strix Halo (gfx1151) is still not detected reliably by all ROCm consumers.
  # Keep the override global for manual llama.cpp/rocminfo sessions, and mirror
  # the service-specific part below for the Ollama daemon.
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.5.1";
    MIOPEN_DEBUG_DISABLE_FIND_DB = "1";
  };

  services.ollama = {
    rocmOverrideGfx = "11.5.1";
    environmentVariables = {
      MIOPEN_DEBUG_DISABLE_FIND_DB = "1";
    };
  };

  systemd.services.llama-cpp-server = {
    description = "llama.cpp server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    unitConfig.ConditionPathExists = llamaCppModel;
    environment = {
      HSA_OVERRIDE_GFX_VERSION = "11.5.1";
      MIOPEN_DEBUG_DISABLE_FIND_DB = "1";
    };
    serviceConfig = {
      Type = "exec";
      DynamicUser = true;
      StateDirectory = "llama-cpp-server";
      WorkingDirectory = "/var/lib/llama-cpp-server";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.llama-cpp-rocm}/bin/llama-server"
        "--model"
        (lib.escapeShellArg llamaCppModel)
        "--host"
        llamaCppHost
        "--port"
        (toString llamaCppPort)
        "--ctx-size"
        "16384"
        "--n-gpu-layers"
        "999"
        "--flash-attn"
        "auto"
        "--metrics"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
      DeviceAllow = [
        "char-drm"
        "char-fb"
        "char-kfd"
      ];
      DevicePolicy = "closed";
      NoNewPrivileges = true;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      ReadOnlyPaths = [ "/var/lib/llama-cpp/models" ];
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      SupplementaryGroups = [ "render" ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service @resources"
        "~@privileged"
      ];
      UMask = "0077";
    };
  };

  workstation.containers.podman.enable = true;
}
