# Rôle AI (local workstation)

## Objectif

Le rôle `ai` prépare un environnement d'IA **local utilisateur** sur une machine de bureau NixOS.

Ce rôle est strictement distinct du rôle `ai-server` qui vivra dans le repo `homelab`.

## Distinction workstation/ai vs homelab/ai-server

| Dimension | `workstation` / `ai` | `homelab` / `ai-server` |
|---|---|---|
| Scope | Usage local, une seule machine | Service partagé, multi-machines |
| Démarrage | Manuel (utilisateur) | Daemon système automatique |
| Réseau | localhost uniquement | Exposé sur le réseau local |
| Cible | Expérimentation personnelle | Infrastructure mutualisée |
| Repo | `workstation` | `homelab` |

**Cette séparation est non-négociable.** Le rôle `ai` de `workstation` ne configure aucun service réseau partagé.

## Contenu

### `modules/apps/ai.nix`

Paquets installés au niveau système :

| Paquet | Rôle |
|---|---|
| `ollama` | Runtime d'inférence LLM local — API sur localhost:11434 |
| `llama-cpp` | Outils CLI llama.cpp — inférence directe GGUF sans daemon |

### `modules/roles/ai.nix`

Configuration système composée :

- Import de `modules/apps/ai.nix`
- `services.flatpak.enable = true` — requis pour AnythingLLM Desktop (non disponible dans nixpkgs)

### `modules/profiles/ai.nix`

Point d'entrée profil : importe `modules/roles/ai.nix`.

## Utilisation

Dans un host :

```nix
# targets/<name>/default.nix
imports = [
  ../../modules/profiles/desktop-hyprland.nix
  ../../modules/profiles/ai.nix
  ../../modules/profiles/networking.nix
];
```

## ollama

ollama est un runtime d'inférence local. Il n'est **pas** démarré automatiquement en tant que service système — c'est l'utilisateur qui le gère.

```bash
# Démarrer le serveur local (localhost:11434)
ollama serve

# Télécharger un modèle
ollama pull llama3

# Lancer une conversation
ollama run llama3

# Lister les modèles disponibles
ollama list
```

Le serveur écoute uniquement sur `localhost` par défaut. Il ne s'expose pas au réseau local.

## llama.cpp

Pour l'inférence directe sans daemon :

```bash
# Inférence directe avec un modèle GGUF
llama-cli -m /path/to/model.gguf -p "Bonjour !"
```

Utile pour le scripting, les benchmarks, ou les cas où ollama n'est pas nécessaire.

## AnythingLLM Desktop

AnythingLLM Desktop n'est pas encore disponible dans nixpkgs. Il s'installe via Flatpak.

Le rôle `ai` active Flatpak (`services.flatpak.enable = true`). Après l'installation du système :

```bash
# Ajouter Flathub (une seule fois)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Installer AnythingLLM Desktop
flatpak install flathub com.anythingllm.anythingllm

# Lancer
flatpak run com.anythingllm.anythingllm
```

AnythingLLM Desktop peut se connecter au serveur ollama local (localhost:11434).

## Accélération GPU

L'accélération GPU pour l'inférence locale repose sur `hardware.graphics.enable = true`, déjà activé par `modules/profiles/desktop-hyprland.nix` via `modules/desktop/default.nix`.

Aucune configuration supplémentaire n'est requise dans le rôle `ai`.

Pour l'inférence GPU avec ollama :

```bash
# Ollama détecte automatiquement CUDA/ROCm si les drivers sont présents
ollama run llama3
```

## Extension

Pour ajouter des outils IA locaux supplémentaires :

1. Ajouter les paquets dans `modules/apps/ai.nix`
2. Ajouter la configuration système dans `modules/roles/ai.nix` si nécessaire
3. Ne pas mettre de logique de service réseau dans ce rôle — c'est le territoire de `homelab/ai-server`
4. Documenter l'ajout dans ce fichier

## Outils intentionnellement absents

| Outil | Raison de l'absence |
|---|---|
| `services.ollama.enable` | Crée un daemon système partagé — hors scope pour workstation |
| `open-webui` (service) | Service réseau — appartient à `homelab/ai-server` |
| Tout service écoutant sur `0.0.0.0` | Hors scope — pas de service mutualisé dans workstation |
