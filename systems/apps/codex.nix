{ pkgs, ... }:
let
  # codex-normal : Codex « premium » avec GPT-5.5 via l'auth OpenAI/ChatGPT
  # existante (codex login). Destiné à l'architecture, l'audit, la revue
  # critique, le refactoring risqué. Aucun secret n'est injecté ici : Codex
  # utilise son propre auth.json / OPENAI_API_KEY hors Nix.
  codexNormal = pkgs.writeShellApplication {
    name = "codex-normal";
    runtimeInputs = [ pkgs.codex ];
    text = ''
      exec codex -m "''${CODEX_NORMAL_MODEL:-gpt-5.5}" "$@"
    '';
  };

  # codex-oss : Codex en mode local/OSS, branché sur Qwen3 Coder Next servi par
  # llama.cpp en OpenAI-compatible (port 8082 par défaut). Destiné aux tâches de
  # code locales bornées dans des workspaces dédiés. Le endpoint local n'exige
  # aucune clé réelle : « no-key-required » est un placeholder non secret, comme
  # côté Hermes. Surcharges possibles :
  #   CODEX_OSS_BASE_URL  (ex. http://127.0.0.1:8090/v1 pour tester le router)
  #   CODEX_OSS_MODEL     (ex. qwen3-coder-next pour l'alias router)
  #   CODEX_OSS_LOCAL_KEY (placeholder de clé locale)
  codexOss = pkgs.writeShellApplication {
    name = "codex-oss";
    runtimeInputs = [ pkgs.codex ];
    text = ''
      base_url="''${CODEX_OSS_BASE_URL:-http://127.0.0.1:8082/v1}"
      model="''${CODEX_OSS_MODEL:-unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL}"
      export CODEX_OSS_LOCAL_KEY="''${CODEX_OSS_LOCAL_KEY:-no-key-required}"
      exec codex \
        -c model_provider=homelab-llama \
        -c 'model_providers.homelab-llama.name="Homelab llama.cpp (Qwen3 Coder Next)"' \
        -c "model_providers.homelab-llama.base_url=\"$base_url\"" \
        -c 'model_providers.homelab-llama.wire_api="chat"' \
        -c 'model_providers.homelab-llama.env_key="CODEX_OSS_LOCAL_KEY"' \
        -m "$model" \
        "$@"
    '';
  };
in
{
  environment.systemPackages =
    import ../../catalog/apps/codex.nix { inherit pkgs; }
    ++ [ codexNormal codexOss ];
}
