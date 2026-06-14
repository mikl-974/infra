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
    ../../../../systems/apps/element-desktop.nix
    ../../../../systems/apps/zed.nix
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
      package = (llamaRocmPkgs.llama-cpp.override {
        rocmSupport = true;
        rocmGpuTargets = [ "gfx1151" ];
      }).overrideAttrs (_old: {
        version = "9999";
        src = inputs.llama-cpp-src;
        npmDepsHash = "sha256-TU4Gv+dd48WDpswhfVtm79IVIOwoCXz1fZ/DI/z40Wg=";
      });
      host = "0.0.0.0";            # Permet les connexions distantes de votre Mac
      fit = "off";
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

      qwen3-coder-next = {
        enable = true;
        autoStart = true;
        mlock = true;               # Garde les poids résidents en RAM (réduit cold start / reload GGUF)
        description = "Qwen3 Coder Next Q5 via llama.cpp (developer local / codex-oss)";
        source = "hf";
        model = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL";
        port = 8082;
        ctxSize = 32768;            # V1 : tâches bornées, une seule grosse session concurrente
        extraArgs = [
          # --- Échantillonnage Qwen3
          "--temp" "1.0"
          "--top-p" "0.95"
          "--min-p" "0.01"
          "--top-k" "40"
          "--alias" "unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL"
          "--repeat-penalty" "1.0"   # VITAL pour éviter les répétitions infinies sur Qwen3
        ];
      };

      # NOTE V1 : le petit Qwen3.5-4B de compression a été retiré. La
      # compression / long-contexte Hermes est désormais confiée au Qwen3.6-35B
      # ci-dessous (port 8081), conformément à la décision V1.

      qwen36-35b-a3b = {
        enable = true;
        autoStart = true;
        mlock = true;               # Modèle chaud : planner/reviewer/compression Hermes
        description = "Qwen3.6 35B A3B UD-Q5_K_XL MTP via llama.cpp (planner/reviewer/compression Hermes)";
        source = "hf";
        model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q5_K_XL";
        port = 8081;                # V1 : remplace l'ancien 8080, libéré par le retrait du 4B
        ctxSize = 65536;            # Contexte long pour compression / résumé Hermes
        extraArgs = [
          "--parallel" "1"
          "--mmproj-url" "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/resolve/main/mmproj-F16.gguf"
          "--spec-type" "draft-mtp"
          "--spec-draft-n-max" "2"
          "--temp" "1.0"
          "--top-p" "0.95"
          "--top-k" "20"
          "--min-p" "0.00"
          "--alias" "unsloth/Qwen3.6-35B-A3B-MTP-GGUF"
        ];
      };

      gemma4-12b = {
         enable = true;
         autoStart = true;
         description = "Gemma 4 12B UD-Q8_K_XL MTP via llama.cpp";
         source = "hf";
         model = "unsloth/gemma-4-12b-it-GGUF:UD-Q8_K_XL";
         port = 8085;
         ctxSize = 65536;
         extraArgs = [
           "--parallel" "1"
           "--no-mmproj"
           "--spec-type" "draft-mtp"
           "--spec-draft-n-max" "2"
           "--reasoning" "on"
           "--alias" "unsloth/gemma-4-12b-it-GGUF"

           # --- Hyperparamètres Officiels Google Gemma 4 ---
           "--temp" "1.0"
           "--top-p" "0.95"
           "--top-k" "64"
           "--repeat-penalty" "1.0"

         ];
       };

     };

    # Router multi-modèles expérimental (port 8090). DÉSACTIVÉ par défaut : il ne
    # remplace pas les services séparés 8081/8082 et sert à comparer router vs
    # instances séparées. AVANT d'activer : vérifier les flags réels du router
    # avec `llama-server --help` sur l'hôte, puis renseigner `extraArgs` (ex. le
    # flag qui charge /var/lib/llama-cpp/router/models.ini). Le preset est généré
    # dès que `enable = true`.
    router = {
      enable = false;
      autoStart = false;
      port = 8090;
      modelsMax = 1;
      parallel = 1;
      mlock = true;
      models = [
        {
          alias = "qwen-3.6-35b";
          model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q5_K_XL";
          ctxSize = 65536;
          extraLines = [ "n-gpu-layers = 999" "mlock = true" ];
        }
        {
          alias = "qwen3-coder-next";
          model = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL";
          ctxSize = 32768;
          extraLines = [ "n-gpu-layers = 999" "mlock = true" ];
        }
      ];
      # extraArgs = [ "--models" "/var/lib/llama-cpp/router/models.ini" ];  # VÉRIFIER le flag réel
      extraArgs = [ ];
    };
   };

   # Optimisation mémoire pour garder les modèles GGUF chauds sans swapper
   # agressivement les poids résidents (cf. --mlock sur les services llama.cpp).
   boot.kernel.sysctl = {
     "vm.swappiness" = 10;
   };

   workstation.dev.postgresql.enable = true;
   workstation.dev.pgweb.enable = true;
   workstation.containers.podman.enable = true;
}
