{ inputs, pkgs, ... }:
let
  llamaRocmPkgs = import inputs.nixpkgs-llama {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      rocmSupport = true;
    };
  };
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
    ../../../../systems/apps/distrobox.nix
    ../../../../systems/apps/claude-code.nix
    ../../../../systems/apps/postgresql.nix
    ../../../../systems/apps/pgweb.nix
    ../../../../systems/bundles/ai-local.nix
    ../../../../systems/bundles/gaming.nix
    ../../../../systems/bundles/rocm-runtime.nix
    ../../../../systems/apps/virt-manager.nix
  ];

  # AnythingLLM is part of the intended workstation setup, but remains
  # installed through Flatpak until nixpkgs has a clean package for it:
  #   flatpak install flathub com.anythingllm.anythingllm

  nixpkgs.config.rocmSupport = true;

  services.printing = {
    enable = true;
    drivers = [
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.brscan4
      pkgs.sane-airscan
    ];
  };

  # Strix Halo (gfx1151) is still not detected reliably by all ROCm consumers.
  # Keep the override global for manual llama.cpp/rocminfo sessions, and mirror
  # the service-specific part below for the Ollama daemon.
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.5.1";
    MIOPEN_DEBUG_DISABLE_FIND_DB = "1";
  };

  infra.ai.inference.llamaCpp = {
    enable = true;

    defaults = {
      package = llamaRocmPkgs.llama-cpp-rocm;
      host = "0.0.0.0";            # Permet les connexions distantes de votre Mac
      fit = "off";
      ctxSize = 65536;            # Contexte unifié à 64k pour Qwen3
      metrics = true;
      enableUnifiedMemory = true;  # Force la gestion UMA (à passer à true pour l'APU AMD)
      openFirewall = true;        # Ouvre automatiquement les ports NixOS (ex: 8082)

      extraArgs = [
        # "--no-mmap"
        # "--no-host"
        "--host" "0.0.0.0"

        # --- Optimisation matérielle Strix Halo UMA (128 Go) ---
        "-ngl" "999"               # Force l'iGPU Radeon 8060S à charger 100% du modèle MoE
        "-fa" "1"                  # Flash Attention indispensable pour économiser la bande passante
          
        # --- Gestion des flux (Désengorgement de la VRAM / Prompt Processing) ---
        "--parallel" "1"           # Dédié à votre seule instance Codex locale
        "--batch-size" "1024"      # Réduit l'allocation maximale par passe d'ingestion (Évite les crashs iGPU)
        "--ubatch-size" "512"      # Micro-batching fluide pour la mémoire unifiée
      ];
    };

    models = {

      qwen3-coder-next-q5 = {
        enable = true;
        autoStart = true;
        description = "Qwen3 Coder Next Q5 via llama.cpp";
        source = "hf";
        model = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL";
        port = 8082;
        fit = "off";
        metrics = false;
        extraArgs = [
          # --- Échantillonnage Qwen3
          "--temp" "1.0" 
          "--top-p" "0.95" 
          "--min-p" "0.01" 
          "--top-k" "40"
          "--repeat-penalty" "1.0"   # VITAL pour éviter les répétitions infinies sur Qwen3
        ];
      };

      qwen36-35b-a3b-q5 = {
        enable = true;
        autoStart = false;
        description = "Qwen3.6 35B A3B UD-Q5_K_XL via llama.cpp";
        source = "hf";
        model = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_XL";
        port = 8080;
        fit = "off";
        metrics = false;
        extraArgs = [
        ];
      };

      qwen36-27b-q5 = {
        enable = true;
        autoStart = false;
        description = "Qwen3.6 27B UD-Q5_K_XL via llama.cpp";
        source = "hf";
        model = "unsloth/Qwen3.6-27B-GGUF:UD-Q5_K_XL";
        port = 8081;
        fit = "off";
        metrics = false;
        extraArgs = [
        ];
      };

      gemma4-31b-q5 = {
        enable = true;
        autoStart = false;
        description = "Gemma 4 31B Q5_K_XL via llama.cpp";
        source = "hf";
        model = "unsloth/gemma-4-31B-it-GGUF:UD-Q5_K_XL";
        port = 8083;
        fit = "off";
        metrics = false;
        extraArgs = [
          "--temp" "1.0" 
          "--top-p" "0.95" 
          "--top-k" "64"
        ];
      };
    };
  };

  workstation.dev.postgresql.enable = true;
  workstation.dev.pgweb.enable = true;
  workstation.containers.podman.enable = true;
}
