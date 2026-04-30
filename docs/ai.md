# IA locale

## Decision retenue

L'IA de `ms-s1-max` est maintenant modelisee comme une capacite locale du host,
pas comme une stack infra.

Le point d'entree unique est :

- `targets/hosts/ms-s1-max/config/capabilities.nix`

## Ce qui est active sur `ms-s1-max`

- `nixpkgs.config.rocmSupport = true`
- `services.ollama.enable = true`
- `services.ollama.package = pkgs.ollama-rocm`
- paquet `ollama-rocm`
- paquet `llama-cpp-rocm`
- paquet `python3Packages.huggingface-hub` (`hf`)
- repertoire persistant `/var/lib/llama-cpp/models`
- paquets systeme `rocm-runtime`, `rocminfo`, `rocm-smi`, `amdsmi`
- paquet `opencode-desktop`
- `services.flatpak.enable = true`
- user `mfo` ajoute au groupe `render`
- override ROCm Strix Halo `HSA_OVERRIDE_GFX_VERSION = "11.5.1"`
- workaround MIOpen `MIOPEN_DEBUG_DISABLE_FIND_DB = "1"`

## Tuning ROCm pour Strix Halo

Sur `ms-s1-max`, le host fixe maintenant explicitement :

- `environment.variables.HSA_OVERRIDE_GFX_VERSION = "11.5.1"`
- `environment.variables.MIOPEN_DEBUG_DISABLE_FIND_DB = "1"`
- `services.ollama.rocmOverrideGfx = "11.5.1"`
- `services.ollama.environmentVariables.MIOPEN_DEBUG_DISABLE_FIND_DB = "1"`

Pourquoi :

- `HSA_OVERRIDE_GFX_VERSION = "11.5.1"` force les consumers ROCm a traiter le
  GPU Strix Halo comme `gfx1151`, ce qui evite les problemes de detection sur
  des builds encore en retard sur cette generation.
- `MIOPEN_DEBUG_DISABLE_FIND_DB = "1"` evite l'usage de la Find DB MIOpen, qui
  peut etre incomplete ou mal calibree sur du materiel recent, et reduit les
  faux demarrages rates sur certaines libs ROCm.

Le repo applique le tuning a deux niveaux :

- globalement via `environment.variables` pour les usages manuels (`llama.cpp`,
  outils ROCm, shells)
- specifiquement dans `services.ollama.*` car les variables de service ne sont
  pas prises depuis le shell utilisateur

## Outils dev associes

Le meme fichier declare aussi les outils de dev relies au poste principal :

- `vscode`
- `jetbrains.rider`
- `jetbrains.webstorm`
- `gitkraken`

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

## Service `llama.cpp` actif

Sur `ms-s1-max`, le repo active aussi un service systemd `llama-cpp-server`
qui demarre en mode serveur sur :

- `127.0.0.1:8080`
- modele par defaut :
  `/var/lib/llama-cpp/models/qwen3.5-35b-a3b/Qwen_Qwen3.5-35B-A3B-Q4_K_M.gguf`

Pourquoi ce choix :

- `Qwen3.5-35B-A3B` est un MoE texte bien adapte au service `llama.cpp`
- la quantization `Q4_K_M` garde un bon compromis qualite / empreinte memoire
  sur `ms-s1-max`
- c'est un GGUF texte unique, donc simple a servir et a remplacer
- il profite du meme tuning ROCm Strix Halo que le reste de la stack locale

Le service fixe aussi :

- `--ctx-size 16384`
- `--n-gpu-layers 999` pour pousser l'offload GPU au maximum
- `--flash-attn auto`
- `--metrics` pour exposer l'endpoint de metriques du serveur

Commandes utiles :

```bash
systemctl status llama-cpp-server
journalctl -u llama-cpp-server -f
curl http://127.0.0.1:8080/health
```

Pour changer de modele, modifier `llamaCppModel` dans
`targets/hosts/ms-s1-max/config/capabilities.nix`.

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
