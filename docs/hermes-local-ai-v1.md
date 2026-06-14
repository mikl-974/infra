# Hermes — orchestration IA locale V1 (ms-s1-max)

Cette page décrit la V1 du moteur IA local de Hermes sur `ms-s1-max`. Elle
complète `docs/hermes-kanban-orchestration.md` (qui couvre le Gateway, le Kanban
et le rôle des profiles) en se concentrant sur les **backends llama.cpp**, les
**wrappers Codex** et le **router expérimental**.

> Le Mac mini n'est pas utilisé dans cette V1. Il reste un poste client
> (voir `home/modules/hermes-client.nix`). Le provider/profile
> `gemma4-mac-mini` existe encore mais n'est pas requis ici.

## Rôle de chaque agent

| Agent | Modèle | Sert via | Rôle |
|---|---|---|---|
| `tech-lead` | Qwen3.6-35B | llama.cpp 8081 | orchestrateur : découpe, coordonne, suit, synthétise |
| `architecte` | GPT-5.5 | `openai-codex` (cloud) | architecture, ADR, design, arbitrage structurant |
| `developer` | Qwen3-Coder-Next | llama.cpp 8082 | implémentation, refactoring, scripts, correctifs |
| `tester` | Qwen3-Coder-Next | llama.cpp 8082 | tests unitaires/intégration/E2E, edge cases |
| `auditeur` | GPT-5.5 | `openai-codex` (cloud) | revue sécurité, performance, risque, conformité |
| `doc-maintainer` | Gemma4-12B | llama.cpp 8085 | README, docs, changelog, exemples |
| `prompt-engineer` | Gemma4-12B | llama.cpp 8085 | prompts, consignes agents, workflows LLM |

Fonctions auxiliaires Hermes :

- **compression / long-contexte** → Qwen3.6-35B (8081, ctx 65536) ;
- **kanban_decomposer / triage_specifier / memory** → Gemma4-12B (8085).

Le routage se fait **par profile/rôle**, pas par nom de modèle. Le modèle reste
une propriété de chaque profile (`targets/hosts/ms-s1-max/config/hermes-agent.nix`).

## codex-normal vs codex-oss

Deux wrappers CLI sont installés dans le profil système
(`systems/apps/codex.nix`) :

- **`codex-normal`** → Codex « premium » avec GPT-5.5 via l'auth OpenAI/ChatGPT
  existante (`codex login`). Pour : architecture, plan d'action phasé, audit de
  repo, revue critique, refactoring risqué, sécurité, arbitrage technique.
  Aucun secret n'est injecté par Nix : Codex utilise son `auth.json` /
  `OPENAI_API_KEY` hors Nix.

  ```bash
  codex-normal --help
  codex-normal "Audit l'architecture du module X et propose un plan phasé"
  # Surcharge éventuelle : CODEX_NORMAL_MODEL=gpt-5.5
  ```

- **`codex-oss`** → Codex en mode local/OSS branché sur Qwen3-Coder-Next servi
  par llama.cpp (8082, OpenAI-compatible). Pour : implémentation locale bornée,
  modifs multi-fichiers, build/test/fix, diff + résumé. Le endpoint local n'exige
  aucune clé réelle ; `no-key-required` est un placeholder **non secret**.

  ```bash
  codex-oss --help
  cd /home/mfo/workspaces/hermes/tasks/TASK-001 && codex-oss
  # Surcharges :
  #   CODEX_OSS_BASE_URL  (def. http://127.0.0.1:8082/v1)
  #   CODEX_OSS_MODEL     (def. unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL)
  #   CODEX_OSS_LOCAL_KEY (def. no-key-required)
  ```

> Ne pas mettre toutes les tâches derrière Codex. Hermes ne doit pas coder
> directement si `codex-oss` est disponible. GPT-5.5 est réservé aux tâches à
> forte valeur (architecture/audit/refactor risqué), pas aux tâches locales
> simples. Qwen3-Coder-Next n'a pas de responsabilité d'architecture et ne reçoit
> que des tâches **bornées** (pas tout l'historique Hermes ni tout le plan).

## Services séparés vs router

### Services séparés (stables, par défaut)

Générés par `infra.ai.inference.llamaCpp` (`systems/apps/llama-cpp.nix`),
config dans `targets/hosts/ms-s1-max/config/capabilities.nix`. User système
dédié `llama-cpp` (jamais root), units durcies, `autoStart = true`.

| Service systemd | Port | ctx | mlock | Concurrence | Rôle |
|---|---|---|---|---|---|
| `llama-cpp-qwen36-35b-a3b` | 8081 | 65536 | oui | `--parallel 1` | planner / reviewer / compression Hermes |
| `llama-cpp-qwen3-coder-next` | 8082 | 32768 | oui | `--parallel 1` | developer (codex-oss) |
| `llama-cpp-gemma4-12b` | 8085 | 65536 | non | `--parallel 1` | decomposer / triage / memory / doc / prompts |

`--mlock` garde les poids du modèle résidents en RAM (réduit cold starts et
rechargements GGUF) **mais ne garantit pas une latence de 0 ms**. Il est couplé à
`LimitMEMLOCK = infinity` sur l'unité. `boot.kernel.sysctl."vm.swappiness" = 10`
limite le swap des poids résidents.

### Router expérimental (opt-in, désactivé par défaut)

`infra.ai.inference.llamaCpp.router` — `llama-router.service`, port **8090**, un
seul endpoint OpenAI-compatible qui sélectionne le modèle par le champ `model`.
Il **ne remplace pas** les services 8081/8082 (gardés en fallback) ; il sert à
comparer router vs instances séparées.

État par défaut : `enable = false`, `autoStart = false`, `modelsMax = 1`,
`parallel = 1`, `mlock = true`. Un preset est généré à
`/var/lib/llama-cpp/router/models.ini` dès l'activation.

> ⚠️ La syntaxe CLI exacte du router dépend de la version de llama.cpp
> installée. **Avant d'activer**, vérifier les flags réels :
>
> ```bash
> sudo -u llama-cpp /run/current-system/sw/bin/llama-server --help | less
> ```
>
> puis renseigner l'invocation vérifiée dans `router.extraArgs` (par ex. le flag
> qui charge `/var/lib/llama-cpp/router/models.ini`). Ne pas supposer que
> `ctx-size`, `model`, `alias` ou `mlock` sont les bons noms d'options si la
> version locale diffère.

Ordre de test recommandé :

1. `modelsMax = 1`, `parallel = 1`, activer le service, tester les 2 alias via
   `/v1/chat/completions` ;
2. si la mémoire tient, passer `modelsMax = 2`, `parallel = 1` ;
3. ne brancher Hermes sur le router (`base_url: http://127.0.0.1:8090/v1`)
   qu'après validation.

Critères de validation : `/v1/models` répond ; les 2 alias répondent ; pas
d'OOM ; pas de rechargement catastrophique entre modèles ; `codex-oss` fonctionne
via le router ; les services séparés restent disponibles en fallback.

## Limites de concurrence (V1)

- Qwen3-Coder-Next / codex-oss : `--parallel 1`, ctx 32768, **une seule** grosse
  session repo active au départ.
- Qwen3.6-35B (planner/reviewer/compression) : `--parallel 1`, ctx 65536 ;
  éventuellement `2` plus tard si la mémoire tient.
- GPT-5.5 (codex-normal) : externe/cloud, hors contrainte locale.
- Router : démarrer à `modelsMax = 1` / `parallel = 1`.

## Workspaces

Le Gateway expose déjà `HERMES_KANBAN_WORKSPACES_ROOT =
/home/mfo/.hermes/kanban/workspaces`. Convention recommandée pour les tâches
pilotées par `codex-oss` (non automatisée en V1) :

```
/home/mfo/workspaces/hermes/tasks/TASK-00X/
  prompt.md          # tâche bornée donnée à codex-oss
  codex-session.log  # trace de session
  diff.patch         # diff produit
  validation.log     # build / tests
  summary.md         # résumé final
```

## Faire évoluer les modèles

1. Éditer le bloc `models.<nom>` dans
   `targets/hosts/ms-s1-max/config/capabilities.nix` (référence HF `model`, `port`,
   `ctxSize`, `mlock`, `extraArgs`).
2. Si le modèle est référencé par Hermes, ajuster le provider correspondant dans
   `targets/hosts/ms-s1-max/config/hermes-agent.nix` (`base_url`,
   `models.<id>.context_length`) et, si besoin, le `model` du profile.
3. `nixos-rebuild test` puis `systemctl status` du service concerné.

## Basculer Hermes du service séparé vers le router

Une fois le router validé, dans `hermes-agent.nix` repointer les providers
`homelab/qwen36` et/ou `homelab/qwen3-coder` vers `http://127.0.0.1:8090/v1`
(et adapter le nom de modèle à l'alias router, ex. `qwen-3.6-35b`,
`qwen3-coder-next`). Garder les services séparés actifs en fallback tant que la
bascule n'est pas éprouvée.

## Commandes de validation

Évaluation / build Nix :

```bash
nix flake check
nix eval .#nixosConfigurations.ms-s1-max.config.system.build.toplevel.drvPath
sudo nixos-rebuild test --flake .#ms-s1-max
```

Services et mémoire verrouillée :

```bash
systemctl status llama-cpp-qwen36-35b-a3b
systemctl status llama-cpp-qwen3-coder-next
systemctl status llama-router          # seulement si router.enable = true

journalctl -u llama-cpp-qwen36-35b-a3b -f
journalctl -u llama-cpp-qwen3-coder-next -f
journalctl -u llama-router -f

systemctl show llama-cpp-qwen36-35b-a3b -p LimitMEMLOCK
systemctl show llama-cpp-qwen3-coder-next -p LimitMEMLOCK
systemctl show llama-router -p LimitMEMLOCK
```

Wrappers :

```bash
codex-normal --help
codex-oss --help
```

Endpoints :

```bash
curl http://127.0.0.1:8081/v1/models    # Qwen3.6-35B
curl http://127.0.0.1:8082/v1/models    # Qwen3-Coder-Next
curl http://127.0.0.1:8090/v1/models    # router (si activé)
```

Qwen3.6-35B via service séparé :

```bash
curl http://127.0.0.1:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"unsloth/Qwen3.6-35B-A3B-MTP-GGUF",
       "messages":[{"role":"user","content":"Réponds en une phrase : quel est ton rôle ?"}],
       "max_tokens":80}'
```

Qwen3-Coder-Next via service séparé :

```bash
curl http://127.0.0.1:8082/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL",
       "messages":[{"role":"user","content":"Écris une fonction C# Add(int a, int b)."}],
       "max_tokens":120}'
```

Via router (alias) :

```bash
curl http://127.0.0.1:8090/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen-3.6-35b","messages":[{"role":"user","content":"Résume en une phrase le rôle du modèle de compression Hermes."}],"max_tokens":80}'

curl http://127.0.0.1:8090/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-coder-next","messages":[{"role":"user","content":"Écris une fonction C# Add(int a, int b)."}],"max_tokens":120}'
```

Surveillance mémoire / GPU :

```bash
free -h
btop
radeontop   # si disponible
```
