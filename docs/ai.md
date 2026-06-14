# IA locale

## Decision retenue

L'IA de `ms-s1-max` est maintenant modelisee comme une capacite locale du host,
pas comme une stack infra.

Le point d'entree unique est :

- `targets/hosts/ms-s1-max/config/capabilities.nix`

## Ce qui est active sur `ms-s1-max`

- `nixpkgs.config.rocmSupport = true`
- paquet `llama-cpp-rocm`
- paquet `python3Packages.huggingface-hub` (`hf`)
- repertoires persistants `/var/lib/llama-cpp/models` et `/var/lib/llama-cpp/cache/*`
- paquets systeme `rocm-runtime`, `rocminfo`, `rocm-smi`, `amdsmi`
- paquet `opencode-desktop`
- paquet `hermes-agent`
- paquet `codex`
- lanceur desktop `hermes-desktop` qui ouvre `hermes desktop`
- `services.flatpak.enable = true`
- user `mfo` ajoute au groupe `render`
- user systeme `llama-cpp` pour les services et caches persistants
- profil Codex local `~/.codex/qwen3-coder.config.toml`
- override ROCm Strix Halo `HSA_OVERRIDE_GFX_VERSION = "11.5.1"`
- workaround MIOpen `MIOPEN_DEBUG_DISABLE_FIND_DB = "1"`

## Tuning ROCm pour Strix Halo

Sur `ms-s1-max`, le host fixe maintenant explicitement :

- `boot.kernelParams = [ "iommu=pt" "amdgpu.gttsize=126976" "ttm.pages_limit=32505856" ]`
- `environment.variables.HSA_OVERRIDE_GFX_VERSION = "11.5.1"`
- `environment.variables.MIOPEN_DEBUG_DISABLE_FIND_DB = "1"`

Pourquoi :

- `iommu=pt` reduit l'overhead IOMMU pour l'acces a la memoire unifiee de l'iGPU.
- `amdgpu.gttsize=126976` reserve jusqu'a 124 Gio de GTT pour l'iGPU.
- `ttm.pages_limit=32505856` aligne la limite de pages epinglees sur ces 124 Gio.
- `HSA_OVERRIDE_GFX_VERSION = "11.5.1"` force les consumers ROCm a traiter le
  GPU Strix Halo comme `gfx1151`, ce qui evite les problemes de detection sur
  des builds encore en retard sur cette generation.
- `MIOPEN_DEBUG_DISABLE_FIND_DB = "1"` evite l'usage de la Find DB MIOpen, qui
  peut etre incomplete ou mal calibree sur du materiel recent, et reduit les
  faux demarrages rates sur certaines libs ROCm.

Le repo applique le tuning a deux niveaux :

- au boot via `boot.kernelParams` pour exposer une enveloppe memoire adaptee a Strix Halo
- globalement via `environment.variables` pour les usages manuels (`llama.cpp`,
  outils ROCm, shells)

## Garde-fou kernel et firmware

Pour `ms-s1-max`, eviter :

- les kernels anterieurs a `6.18.4` pour les charges ROCm `gfx1151`
- `linux-firmware-20251125`, connu pour casser ROCm sur Strix Halo

Verification rapide :

```bash
uname -r
cat /proc/cmdline
journalctl -b | rg 'Command line:|amdgpu.gttsize|ttm.pages_limit'
```

Si la machine utilise une base RPM ou si vous comparez avec une install Fedora,
la version du firmware se verifie aussi avec :

```bash
rpm -qa | grep linux-firmware
```

Sur NixOS, garder le meme principe : verifier les regressions firmware/kernel
avant mise a jour de la pile ROCm ou avant d'attribuer un crash a `llama.cpp`.

Pour le moment, Ollama est retire de la configuration active : le tuning ROCm
reste donc porte au niveau host pour `llama.cpp` direct et les outils ROCm.

## Outils dev associes

Le meme fichier declare aussi les outils de dev relies au poste principal :

- `vscode`
- `jetbrains.rider`
- `jetbrains.webstorm`
- `gitkraken`
- `hermes`

## Ajouter un modele llama.cpp manuellement

Le repo installe la CLI Hugging Face `hf` mais ne place pas les poids de modeles
dans le `/nix/store`.

Pour `llama.cpp`, utiliser des fichiers `GGUF` et les stocker sous :

```bash
/var/lib/llama-cpp/models
```

Authentification Hugging Face si le modele est restreint :

```bash
hf auth login
```

Telechargement d'un modele GGUF :

```bash
mkdir -p /var/lib/llama-cpp/models/<modele>
hf download <repo-hf> <fichier.gguf> \
  --local-dir /var/lib/llama-cpp/models/<modele>
```

Exemple de lancement manuel :

```bash
llama-server -m /var/lib/llama-cpp/models/<modele>/<fichier.gguf>
```

Le repertoire est cree declarativement par NixOS et reste hors du store pour
permettre des tests de quantizations ou de variantes sans rebuild systeme.

## Services `llama.cpp`

> ⚠️ Le layout V1 à jour (ports, contextes, mlock, router, wrappers Codex) fait
> autorité dans **`docs/hermes-local-ai-v1.md`**. Les ports/noms ci-dessous
> peuvent être historiques ; en cas de doute, vérifier
> `targets/hosts/ms-s1-max/config/capabilities.nix`. Layout actuel : Qwen3.6-35B
> sur 8081, Qwen3-Coder-Next (ctx 32k) sur 8082, Gemma4-12B sur 8085.

Le repo ne garde plus un service systemd `llama-cpp-server` code en dur.
`systems/apps/llama-cpp.nix` expose maintenant un module declaratif
`infra.ai.inference.llamaCpp` qui :

- genere un service systemd par modele
- separe les defaults moteur des declarations de modeles du host
- garde `llama.cpp` distinct de `ollama`, qui n'est pas active actuellement
- laisse les futurs routeurs/UI hors du moteur d'inference

Sur `ms-s1-max`, `targets/hosts/ms-s1-max/config/capabilities.nix` declare :

- `llama-cpp-qwen3-coder-next-q5.service`
- `llama-cpp-qwen36-35b-a3b-q5.service`
- `llama-cpp-qwen36-27b-q5.service`
- `llama-cpp-gemma4-31b-q5.service`

Le host fixe des defaults `llama.cpp` adaptes a Strix Halo :

- `package = llamaRocmPkgs.llama-cpp-rocm`
- `host = "0.0.0.0"`
- `ctxSize = 65536`
- `-fit off`
- `openFirewall = true`
- `-fa 1`
- `-ngl 999`
- `--parallel 1`
- `--batch-size 1024`
- `--ubatch-size 512`
- `GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1"`

Modeles servis :

- `qwen3-coder-next`
  - source Hugging Face : `unsloth/Qwen3-Coder-Next-GGUF:UD-Q5_K_XL`
  - bind `0.0.0.0:8082`
  - autostart active
- `qwen36-35b-a3b`
  - source Hugging Face : `unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q5_K_XL`
  - bind `0.0.0.0:8080`
  - autostart desactive
- `gemma4-12b`
  - source Hugging Face : `unsloth/gemma-4-31B-it-GGUF:UD-Q5_K_XL`
  - bind `0.0.0.0:8083`
  - autostart desactive, donc non accessible apres reboot tant qu'il n'est pas lance manuellement

Codex utilise un profil dedie :

- `~/.codex/qwen3-coder.config.toml`
- catalogue local `~/.codex/model-catalogs/qwen3-coder-next.json`
- provider `llamacpp-local`
- base URL `http://127.0.0.1:8082/v1`
- `web_search = "disabled"`
- features `apps`, `plugins`, `multi_agent`, `computer_use`, browser et image desactivees
- MCP `node_repl` desactive

Le profil optionnel suffit pour `codex --profile qwen3-coder`. Pour que Codex
App affiche le modele dans son selecteur, la configuration globale doit aussi
pointer vers ce catalogue via `model_catalog_json`; le profil seul ne suffit pas.
Le catalogue n'active pas `apply_patch_tool_type`, car cela force un tool
`custom` incompatible avec `llama.cpp`.

Ces desactivations sont necessaires avec `llama.cpp` : Codex envoie sinon des
tools natifs `namespace`, `web_search` ou `image_generation`, alors que
`llama.cpp` accepte uniquement des tools OpenAI `function`.

Le module cree aussi les repertoires persistants :

- `/var/lib/llama-cpp/cache`
- `/var/lib/llama-cpp/cache/huggingface`
- `/var/lib/llama-cpp/cache/llama`
- `/var/lib/llama-cpp/models`

et utilise un user systeme dedie pour rendre les caches HF persistants et
fiables entre redemarrages.

Les services Hugging Face attendent aussi `network-online.target` et continuent
de retenter le demarrage apres boot au lieu de rester bloques en echec si le
reseau n'etait pas encore pret au premier lancement.

Commandes utiles :

```bash
systemctl list-unit-files 'llama-cpp-*'
systemctl status llama-cpp-qwen3-coder-next-q5
journalctl -u llama-cpp-qwen3-coder-next-q5 -f
curl http://127.0.0.1:8082/health
codex debug models | grep qwen3-coder-next
codex --profile qwen3-coder exec --ephemeral "Reply with exactly: ok"
sudo systemctl start llama-cpp-qwen36-35b-a3b-q5
sudo systemctl start llama-cpp-qwen36-27b-q5
sudo systemctl start llama-cpp-gemma4-31b-q5
```

## AnythingLLM

`AnythingLLM` n'est pas package proprement dans `nixpkgs` aujourd'hui.
Le repo retient donc la position explicite suivante :

- Flatpak est active sur `ms-s1-max`
- l'installation de l'app reste :

```bash
flatpak install flathub com.anythingllm.anythingllm
```

Ce choix est documente et assume.
Il evite de reintroduire un faux module "IA local" abstrait qui cacherait la
realite de ce que la machine installe effectivement.
