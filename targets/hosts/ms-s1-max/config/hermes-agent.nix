{ inputs, pkgs, ... }:
let
  # La variante `.default` n'embarque pas le groupe de dépendances `matrix`
  # (mautrix[encryption], asyncpg, aiosqlite, aiohttp-socks, Markdown). Sans lui
  # l'adaptateur Matrix échoue silencieusement au démarrage du gateway et le
  # dashboard reste bloqué sur « gateway has not reported a connection yet ».
  hermesPackage = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    extraDependencyGroups = [ "matrix" ];
  };
  hermesHome = "/home/mfo/.hermes";
  terminalCwd = "/home/mfo/infra";

  # Endpoints llama.cpp locaux : aucune authentification réelle. Hermes exige
  # néanmoins qu'une clé soit présente pour considérer le provider « configuré »
  # (sinon : « No API key configured for provider 'custom' » et resume échoue
  # avec « No LLM provider configured »). « no-key-required » est le placeholder
  # qu'Hermes utilise lui-même pour les endpoints locaux — ce n'est pas un secret.
  localApiKey = "no-key-required";
  customProviders = [
    {
      name = "homelab/qwen3-coder";
      base_url = "http://127.0.0.1:8082/v1";
      api_key = localApiKey;
      models.qwen3-coder.context_length = 262144;
    }
    {
      name = "homelab/qwen36";
      base_url = "http://127.0.0.1:8080/v1";
      api_key = localApiKey;
      models."unsloth/Qwen3.6-35B-A3B-MTP-GGUF".context_length = 65536;
    }
    {
      name = "homelab/qwen35";
      base_url = "http://127.0.0.1:8081/v1";
      api_key = localApiKey;
      models."unsloth/Qwen3.5-4B-GGUF:UD-Q4_K_XL".context_length = 65536;
    }
    {
      name = "homelab/gemma4";
      base_url = "http://127.0.0.1:8085/v1";
      api_key = localApiKey;
      models."unsloth/gemma-4-12b-it-GGUF".context_length = 262144;
    }
  ];

  commonProfileSettings = {
    custom_providers = customProviders;

    terminal = {
      backend = "local";
      modal_mode = "auto";
      cwd = terminalCwd;
      timeout = 180;
      persistent_shell = true;
    };

    compression = {
      enabled = true;
      threshold = 0.5;
      target_ratio = 0.2;
      protect_last_n = 20;
      protect_first_n = 3;
    };

    display = {
      interface = "cli";
      streaming = true;
      show_reasoning = true;
      tool_progress = "all";
      inline_diffs = true;
      final_response_markdown = "strip";
    };

    memory = {
      memory_enabled = true;
      user_profile_enabled = true;
      provider = "custom:homelab/gemma4";
      write_approval = false;
    };

    kanban = {
      dispatch_in_gateway = false;
      dispatch_interval_seconds = 60;
      failure_limit = 2;
    };

    approvals = {
      mode = "smart";
      timeout = 60;
      cron_mode = "deny";
      destructive_slash_confirm = false;
    };

    toolsets = [
      "hermes-cli"
      "web"
    ];
  };

  mkProfileSettings =
    { model
    , provider
    , reasoning ? "medium"
    , baseUrl ? ""
    }:
    commonProfileSettings // {
      model = {
        default = model;
        provider = provider;
      } // (if baseUrl == "" then { } else { base_url = baseUrl; });

      agent = {
        max_turns = 150;
        gateway_timeout = 1800;
        restart_drain_timeout = 180;
        api_max_retries = 3;
        tool_use_enforcement = "auto";
        task_completion_guidance = true;
        environment_probe = true;
        coding_context = "auto";
        gateway_timeout_warning = 900;
        clarify_timeout = 600;
        gateway_notify_interval = 180;
        gateway_auto_continue_freshness = 3600;
        image_input_mode = "auto";
        disabled_toolsets = [ ];
        reasoning_effort = reasoning;
        verbose = false;
      };

      auxiliary = {
        compression = {
          provider = "custom:homelab/qwen35";
          model = "unsloth/Qwen3.5-4B-GGUF:UD-Q4_K_XL";
          timeout = 120;
          context_length = 65536;
          extra_body = { };
        };
        kanban_decomposer = {
          provider = "custom:homelab/gemma4";
          model = "unsloth/gemma-4-12b-it-GGUF";
          timeout = 180;
          extra_body = { };
        };
        triage_specifier = {
          provider = "custom:homelab/gemma4";
          model = "unsloth/gemma-4-12b-it-GGUF";
          timeout = 120;
          extra_body = { };
        };
      };
    };

  qwenCoderProfile = mkProfileSettings {
    model = "qwen3-coder";
    provider = "custom:homelab/qwen3-coder";
    reasoning = "high";
  };

  gemmaProfile = mkProfileSettings {
    model = "unsloth/gemma-4-12b-it-GGUF";
    provider = "custom:homelab/gemma4";
    reasoning = "high";
  };

  codexProfile = reasoning: mkProfileSettings {
    model = "gpt-5.5";
    provider = "openai-codex";
    reasoning = reasoning;
  };
in
{
  imports = [
    ../../../../systems/apps/hermes-agent.nix
  ];

  homelab.services.hermes = {
    enable = true;
    user = "mfo";
    home = hermesHome;
    binary = "${hermesPackage}/bin/hermes";

    gateway.enable = true;
    workspaces.enable = true;
    desktop.enable = true;
    kanban.dispatchInGateway = true;

    settings = {
      model = {
        default = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
        provider = "custom:homelab/qwen36";
      };

      custom_providers = customProviders;
      fallback_providers = [ ];
      credential_pool_strategies = { };
      toolsets = [
        "hermes-cli"
        "web"
      ];

      agent = {
        max_turns = 150;
        gateway_timeout = 1800;
        restart_drain_timeout = 180;
        api_max_retries = 3;
        tool_use_enforcement = "auto";
        task_completion_guidance = true;
        environment_probe = true;
        coding_context = "auto";
        gateway_timeout_warning = 900;
        clarify_timeout = 600;
        gateway_notify_interval = 180;
        gateway_auto_continue_freshness = 3600;
        image_input_mode = "auto";
        disabled_toolsets = [ ];
        reasoning_effort = "medium";
        verbose = false;
      };

      terminal = {
        backend = "local";
        modal_mode = "auto";
        cwd = terminalCwd;
        timeout = 180;
        persistent_shell = true;
      };

      auxiliary.compression = {
        provider = "custom:homelab/qwen35";
        model = "unsloth/Qwen3.5-4B-GGUF:UD-Q4_K_XL";
        timeout = 120;
        context_length = 65536;
        extra_body = { };
      };

      display = {
        interface = "cli";
        streaming = true;
        show_reasoning = true;
        tool_progress = "all";
        inline_diffs = true;
        file_mutation_verifier = true;
        final_response_markdown = "strip";
        platforms = {
          telegram.streaming = true;
          discord.streaming = false;
        };
      };

      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        provider = "builtin";
        write_approval = false;
      };

      stt = {
        enabled = true;
        provider = "local";
        local.model = "base";
      };

      tts = {
        provider = "edge";
        edge.voice = "en-US-AriaNeural";
      };

      slack = {
        require_mention = true;
        free_response_channels = "";
        allowed_channels = "";
        channel_prompts = { };
      };

      discord = {
        require_mention = true;
        free_response_channels = "";
        allowed_channels = "";
        auto_thread = true;
        thread_require_mention = false;
        history_backfill = true;
        history_backfill_limit = 50;
        reactions = true;
        channel_prompts = { };
      };

      telegram = {
        reactions = false;
        channel_prompts = { };
        allowed_chats = "";
      };

      whatsapp.model = {
        default = "unsloth/gemma-4-12b-it-GGUF";
        provider = "custom:homelab/gemma4";
      };

      matrix = {
        require_mention = true;
        free_response_rooms = "";
        allowed_rooms = "";
        extra = {
          allowed_rooms = "";
          require_mention = true;
        };
        model = {
          default = "unsloth/gemma-4-12b-it-GGUF";
          provider = "custom:homelab/gemma4";
        };
      };

      platforms = {
        line.enabled = false;
        matrix.enabled = true;
        whatsapp.enabled = false;
      };

      platform_toolsets = {
        cli = [ "hermes-cli" ];
        discord = [ "hermes-discord" ];
        google_chat = [ "hermes-google_chat" ];
        homeassistant = [ "hermes-homeassistant" ];
        qqbot = [ "hermes-qqbot" ];
        signal = [ "hermes-signal" ];
        slack = [ "hermes-slack" ];
        teams = [ "hermes-teams" ];
        telegram = [ "hermes-telegram" ];
        whatsapp = [ "hermes-whatsapp" ];
        yuanbao = [ "hermes-yuanbao" ];
      };

      approvals = {
        mode = "smart";
        timeout = 60;
        cron_mode = "deny";
        mcp_reload_confirm = true;
        destructive_slash_confirm = false;
      };

      kanban = {
        dispatch_in_gateway = true;
        dispatch_interval_seconds = 60;
        failure_limit = 2;
        worker_log_rotate_bytes = 2097152;
        worker_log_backup_count = 1;
        auto_decompose = true;
        auto_decompose_per_tick = 3;
        dispatch_stale_timeout_seconds = 14400;
      };

      gateway = {
        strict = false;
        media_delivery_allow_dirs = [ ];
        trust_recent_files = true;
        trust_recent_files_seconds = 600;
      };

      compression = {
        enabled = true;
        threshold = 0.5;
        target_ratio = 0.2;
        protect_last_n = 20;
        protect_first_n = 3;
      };

      prompt_caching.cache_ttl = "5m";
      group_sessions_per_user = true;
      session_reset = {
        mode = "none";
        at_hour = 4;
        idle_minutes = 1440;
      };
    };

    profiles = {
      tech-lead = {
        description = "Agent orchestrateur / tech lead qui découpe le travail, coordonne développeur, architecte et prompt engineer, arbitre les priorités et vérifie la livraison. Utilise Gemma 4, incluant le routage des sujets documentation vers doc-maintainer, incluant les spécialistes tests et audit.";
        settings = mkProfileSettings {
          model = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
          provider = "custom:homelab/qwen36";
          reasoning = "medium";
        };
        soul = ''
          # Orchestrateur / Tech Lead Agent

          Tu es l’agent Orchestrateur et Tech Lead de Mickael. Réponds en français par défaut.

          Mission principale : comprendre l’objectif, découper le travail, choisir le bon agent/spécialiste, suivre l’avancement et garantir une livraison vérifiée.

          Règles de travail :
          - Commence par reformuler l’objectif et identifier les inconnues bloquantes.
          - Découpe les tâches en unités livrables avec critères d’acceptation.
          - Délègue aux profiles spécialisés via Kanban.
          - Route mentalement les sujets : implémentation -> developer, architecture -> architecte, prompts/workflows LLM -> prompt-engineer, documentation -> doc-maintainer.
          - Exige des preuves de validation : tests, builds, logs, liens, fichiers modifiés.
          - Garde la réponse concise, orientée décision et prochaines actions.
          - Route les sujets de tests vers tester.
          - Route les sujets d'audit vers auditeur.
        '';
      };

      architecte = {
        description = "Agent architecte logiciel pour décisions d’architecture, ADR, frontières de modules, conception API et revues de design. Utilise GPT-5.5 via OpenAI Codex OAuth.";
        settings = codexProfile "high";
        soul = ''
          # Architecte Agent

          Tu es l’agent Architecte logiciel de Mickael. Réponds en français par défaut.

          Mission principale : clarifier l’architecture, les compromis, les risques et les trajectoires d’évolution.

          Règles de travail :
          - Commence par comprendre les contraintes existantes du dépôt et les invariants.
          - Propose des options avec compromis explicites plutôt qu’une seule réponse dogmatique.
          - Préfère les designs simples, testables et évolutifs.
          - Identifie les impacts sur sécurité, données, observabilité, déploiement et maintenance.
          - Quand une décision est structurante, formule-la comme une mini-ADR.
        '';
      };

      developer = {
        description = "Agent développeur senior orienté implémentation, debugging, tests et refactoring dans les codebases applicatives. Utilise Qwen3 Coder Next.";
        settings = qwenCoderProfile;
        soul = ''
          # Developer Agent

          Tu es l’agent Développeur senior de Mickael. Réponds en français par défaut.

          Mission principale : transformer les décisions techniques en code fiable, testé et maintenable.

          Règles de travail :
          - Inspecte toujours les fichiers existants avant de modifier.
          - Privilégie les changements minimaux, cohérents avec le style du dépôt.
          - Écris ou adapte les tests pertinents et vérifie réellement le résultat.
          - Signale clairement les risques, migrations ou effets de bord.
          - Ne fais pas de refactor opportuniste sans raison liée à la tâche.
        '';
      };

      tester = {
        description = "Agent QA / Test Engineer spécialisé dans la rédaction de tests unitaires, d'intégration, de tests E2E et l'identification de cas limites (edge cases). Utilise Qwen3 Coder.";
        settings = qwenCoderProfile // {
          agent = qwenCoderProfile.agent // { reasoning_effort = "medium"; };
        };
        soul = ''
          # Test Engineer Agent

          Tu es l’agent Test Engineer de Mickael. Réponds en français par défaut.

          Mission principale : garantir la robustesse du code par une couverture de tests exhaustive et intelligente.

          Règles de travail :
          - Identifie les chemins critiques et les cas limites (edge cases) pour chaque fonctionnalité.
          - Rédige des tests unitaires clairs, maintenables et isolés (utilisant des mocks si nécessaire).
          - Propose des scénarios de tests d'intégration et de tests d'acceptation (E2E).
          - Analyse les échecs de tests pour identifier les causes racines et suggérer des correctifs.
          - Vérifie toujours que les tests sont réalisables dans l'environnement actuel.
        '';
      };

      auditeur = {
        description = "Agent Audit & Sécurité pour la revue de code, la recherche de vulnérabilités, l'analyse de performance et la conformité aux standards. Utilise GPT-5.5.";
        settings = codexProfile "medium";
        soul = ''
          # Audit & Security Agent

          Tu es l’agent Auditeur de Mickael. Réponds en français par défaut.

          Mission principale : assurer la qualité, la sécurité et la performance du code via des audits rigoureux.

          Règles de travail :
          - Analyse le code sous l'angle de la sécurité (OWASP, injections, fuites de données).
          - Identifie les goulots d'étranglement de performance et les complexités algorithmiques excessives.
          - Vérifie la conformité avec les standards de l'entreprise et les principes de clean code.
          - Signale les dettes techniques critiques et les risques d'architecture.
          - Fournis des recommandations précises et actionnables pour chaque point d'audit.
        '';
      };

      doc-maintainer = {
        description = "Agent responsable de maintenir la documentation: README, guides, ADR, docs développeur, exemples et synchronisation avec le code réel. Utilise Gemma 4.";
        settings = gemmaProfile;
        soul = ''
          # Documentation Maintainer Agent

          Tu es l’agent Documentation Maintainer de Mickael. Réponds en français par défaut.

          Mission principale : maintenir une documentation exacte, utile et synchronisée avec le code réel du dépôt.

          Règles de travail :
          - Traite le code exécutable et les manifests comme source de vérité avant la prose existante.
          - Cherche les docs obsolètes, ambiguës ou contradictoires et propose/édite des corrections ciblées.
          - Préserve la structure et le style des documents existants.
          - Ajoute des exemples, commandes et prérequis seulement s’ils sont vérifiables dans le repo.
          - Pour chaque changement de doc, vérifie les liens, chemins de fichiers, commandes citées et noms de projets.
          - Signale les informations incertaines au lieu de les inventer.
          - Si une modification de code change le comportement public, mets à jour README, docs, guides et notes de migration pertinentes.
        '';
      };

      prompt-engineer = {
        description = "Agent prompt engineer spécialisé dans la rédaction, l’amélioration et l’évaluation de prompts, instructions système, rubriques et workflows LLM. Utilise Gemma 4.";
        settings = gemmaProfile;
        soul = ''
          # Prompt Engineer Agent

          Tu es l’agent Prompt Engineer de Mickael. Réponds en français par défaut.

          Mission principale : concevoir des prompts robustes, précis et évaluables pour agents et LLMs.

          Règles de travail :
          - Transforme les besoins flous en objectifs, contraintes, entrées/sorties et critères d’évaluation.
          - Préfère des prompts courts mais complets, avec structure claire.
          - Ajoute des garde-fous contre les ambiguïtés, hallucinations et sorties non vérifiables.
          - Fournis si utile des variantes : concise, stricte, créative, agentique.
          - Inclue des exemples seulement quand ils améliorent réellement le comportement attendu.
        '';
      };
    };
  };
}
