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

Si le GPU AMD est mal detecte par ROCm, le host peut aussi fixer :

- `services.ollama.rocmOverrideGfx = "<gfx-version>"`

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
