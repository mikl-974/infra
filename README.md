# workstation

Repository dedie aux machines utilisateur personnelles (NixOS desktop, Hyprland, dotfiles, devShells), separe du scope `homelab`.

## Dependance partagee : `foundation`

Ce repo consomme [`mikl-974/foundation`](https://github.com/mikl-974/foundation) comme socle partage.

Briques consommees depuis `foundation` :

| Brique | Source | Raison |
|---|---|---|
| Tailscale | `foundation.nixosModules.networkingTailscale` | reseau generique, partage entre machines |

Briques conservees dans `workstation` :

| Brique | Raison |
|---|---|
| devShell `.NET` | environnement CLI de dev personnel (SDK, Docker, playwright) — pas une brique generique |
| Noctalia | theme et identite visuelle du poste — strictement personnel |
| Hyprland + first-boot UX | specifique machines utilisateur |
| Cloudflare WARP | client VPN desktop, pas une primitive infra generique |
| Podman (profil dev local) | moteur de containers local de developpement, couple au profil dev et a une UX workstation |
| Solaar / Bluetooth / Wi-Fi desktop | gestion locale des peripheriques et applets desktop — pas une primitive infra partagee |
| Daily apps desktop | applications quotidiennes de base (web, PDF, images, fichiers, partage local) — specifiques a l'usage desktop |
| Editeurs / IDE / apps dev desktop | VS Code, Rider, WebStorm, Neovim, GitKraken — applications desktop dev |
| theming / dotfiles | strictement desktop / utilisateur |

## Separation desktop / daily / utilities / dev / gaming / ai / shell

| Couche | Ce qu'elle contient | Localisation |
|---|---|---|
| Base desktop | Hyprland, terminal, audio, Noctalia, WARP, Bluetooth, Wi-Fi, Solaar, daily apps, utilities | `profiles/desktop-hyprland.nix` |
| Daily apps | navigateurs, PDF, images, fichiers, archives, partage local, confort desktop | `modules/apps/daily.nix` |
| Utilities desktop | pavucontrol, brightnessctl, playerctl, nm-connection-editor | `modules/apps/utilities.nix` + `modules/desktop/connectivity.nix` |
| Dev utilisateur | VS Code, Rider, WebStorm, Neovim, GitKraken, CLI outils systeme, Podman local | `profiles/dev.nix` |
| Gaming | Steam, Proton, Lutris, Bottles, mangohud, gamescope | `profiles/gaming.nix` |
| AI local | ollama, llama-cpp, Flatpak (AnythingLLM Desktop) | `profiles/ai.nix` |
| Shell `.NET` | SDK .NET, Docker CLI, playwright | `devshells/dotnet.nix` |

Les IDEs sont des applications desktop. Ils sont installes en tant que paquets systeme
via `profiles/dev.nix` → `modules/apps/editors.nix`.
Le shell `.NET` fournit les runtimes et outils CLI avec lesquels ces editeurs travaillent.

## Structure

- `targets/` : machines concretes (`main`, `laptop`, `gaming`) — chaque machine a un `vars.nix`
- `modules/` : modules Nix cibles par domaine, profils, devshells, templates
  - `modules/profiles/` : assemblages reutilisables (`desktop-hyprland`, `dev`, `gaming`, `ai`, `networking`)
  - `modules/devshells/` : environnements de developpement CLI locaux
  - `modules/templates/` : templates de configuration (host-vars.nix)
  - `modules/containers/` : moteurs de containers locaux de dev
- `home/` : composition de la configuration utilisateur (Home Manager)
  - `home/users/` : configuration par utilisateur
  - `home/roles/` : compositions de roles reutilisables (placeholder)
  - `home/targets/` : overrides par machine (placeholder)
- `dotfiles/` : bibliotheque de configurations applicatives, organisee par app/domaine
  - `hyprland/`, `terminal/`, `launchers/`, `notifications/`, `themes/`, `shell/`, `editors/`
- `stacks/` : services et applications (placeholder — les stacks serveur vivent dans `homelab`)
- `secrets/` : secrets chiffres (placeholder)
- `docs/` : documentation d'architecture et d'usage
- `scripts/` : orchestration, validation, verification (ne redefinissent pas la configuration)
- `flake.nix` : point d'entree unique

## Configuration machine (vars.nix)

Chaque machine est configurée via `targets/<name>/vars.nix`.
**C'est le seul fichier à éditer pour configurer une machine.**
Les fichiers structurants (`flake.nix`, `default.nix`, `disko.nix`) lisent leurs valeurs depuis ce fichier.

```nix
# targets/main/vars.nix
{
  system   = "x86_64-linux";
  username = "mikl";
  hostname = "main";
  disk     = "/dev/nvme0n1";
  timezone = "Europe/Paris";
  locale   = "fr_FR.UTF-8";
}
```

## Separation des responsabilites

- **target** : machine concrete + combinaison de profils
- **vars.nix** : valeurs spécifiques à l'instance machine, dans `targets/<name>/vars.nix`
- **profile** : composition de rôles et de briques fonctionnelles
- **role** : composition d'apps + configuration système liée à un usage (gaming, ai)
- **module** : logique Nix isolee et reutilisable (apps, desktop, theming, shell)
- **home** : configuration utilisateur (Home Manager)
- **dotfiles** : configuration applicative brute (configs INI, CSS, conf)
- **devShell** : outillage CLI/runtime dev local, specifique au poste de travail

## Utilities desktop

La workstation inclut une couche utilitaire desktop propre pour eviter de disperser :

- les applications quotidiennes dans `modules/apps/daily.nix`
- les applications utilitaires dans `modules/apps/utilities.nix`
- la connectivite locale et les integrations systeme dans `modules/desktop/connectivity.nix`

Repartition retenue :

| Couche | Contenu |
|---|---|
| `modules/apps/daily.nix` | apps quotidiennes de base (Firefox, Chromium, Zathura, imv, Thunar, File Roller, LocalSend, cliphist, mako) |
| `modules/apps/utilities.nix` | outils utilisateur quotidiens (pavucontrol, brightnessctl, playerctl, nm-connection-editor) |
| `modules/desktop/connectivity.nix` | NetworkManager, nm-applet, Bluetooth, Blueman, Solaar via `hardware.logitech.wireless.*` |

Solaar reste dans `workstation` car il gere des peripheriques desktop locaux (Logitech), avec des besoins udev et d'integration utilisateur. Ce n'est pas une brique `foundation`.
Les daily apps restent distinctes des utilities : elles couvrent l'usage utilisateur courant, pas les helpers techniques.

## Theming : Noctalia

Noctalia est le schema de couleurs et l'identite visuelle de cette workstation.

Le module systeme est dans `modules/theming/noctalia.nix`.
Les assets visuels (palette, CSS, wallpapers) vivent dans `dotfiles/themes/noctalia/`.

Voir `docs/theming.md`.

## DevShell .NET

Entrer dans le shell :

```bash
nix develop .#dotnet
```

Contenu : `dotnet-sdk`, `git`, `curl`, `jq`, `openssl`, `pkg-config`, `docker-client`, `playwright`.

Les IDEs (VS Code, Rider, WebStorm) sont installes comme paquets systeme, pas dans le shell.

Voir `docs/devshells.md`.

Voir aussi `docs/daily-apps.md`, `docs/utilities.md`, `docs/profiles.md`, `docs/devshells.md`, `docs/tool-placement.md` et `docs/update-workflow.md`.

## Structure monorepo progressive

Ce repo est progressivement reorganise en monorepo avec un decoupage interne :

- `targets/` : machines concretes (ne contient pas de briques generiques)
- `modules/` : tout ce qui est reutilisable (profils, devshells, templates, modules techniques)
- `home/` : composition utilisateur / roles / cibles
- `dotfiles/` : bibliotheque de configs applicatives par app/domaine
- `stacks/` : placeholder — les services serveur vivent dans `homelab`
- `secrets/` : placeholder pour la gestion declarative de secrets future

Voir `docs/architecture.md` et les `README.md` de chaque dossier pour les regles detaillees.

## Placement des nouvelles briques

La decision architecturale pour les briques Cockpit / apps / containers est documentee dans :

- `docs/tool-placement.md`

Resume :

- `Cockpit` + plugins Cockpit + base VMs -> `homelab`
- `GitKraken`, `Podman`, `Chromium`, `LocalSend`, `Neovim`, `NordVPN` -> `workstation`

Dans cette passe `workstation`, les integrations locales effectivement branchees sont :

- `Chromium` et `LocalSend` dans `modules/apps/daily.nix`
- `Neovim` dans `modules/apps/editors.nix`
- `GitKraken` dans `modules/apps/dev.nix`
- `Podman` dans `modules/containers/podman.nix` via `modules/profiles/dev.nix`

`NordVPN` reste documente mais non implemente ici faute de module/package officiel stable dans la base Nix disponible pour cette passe.

## First boot / UX Hyprland

La base desktop ne se limite plus a installer Hyprland et des paquets :

- `mako` est demarre explicitement dans la session Hyprland
- `cliphist` est branche via `wl-paste --watch`
- les dotfiles `hyprland`, `terminal`, `launchers` et `notifications` sont lies par Home Manager
- la session a des bindings de base utiles des le premier login

Voir `docs/first-boot.md` et `docs/hyprland.md`.

## Installer une machine

### 1. Initialiser la configuration machine

```bash
# Crée targets/main/vars.nix interactivement
nix run .#init-host -- main
```

Ou copier le template et éditer directement :

```bash
cp modules/templates/host-vars.nix targets/main/vars.nix
# éditer targets/main/vars.nix
```

### 2. Diagnostiquer le repo et le host

```bash
nix run .#doctor -- --host main
```

### 3. Valider la configuration du host

```bash
nix run .#validate-install -- main
```

### 4. Afficher la config effective

```bash
nix run .#show-config -- main
```

### 5. Installer

**Via NixOS Anywhere (recommandé)** :

```bash
nix run .#install-anywhere -- main <IP-CIBLE>
```

**Installation manuelle (fallback)** :

```bash
nix run .#install-manual -- --host main
```

Voir `docs/nixos-anywhere.md`, `docs/manual-install.md`, `docs/bootstrap.md` et `docs/first-boot.md`.

## Validation et vérification

Avant l'installation :

```bash
nix run .#doctor -- --host main
nix run .#validate-install -- main
```

Après l'installation :

```bash
nix run .#post-install-check -- --host main
```

Checklist opératoire : `docs/install-checklist.md`

## Mise a jour depuis la machine

Workflow local recommande :

```bash
cd ~/workstation
git pull --ff-only
sudo nixos-rebuild switch --flake .#$(hostname)
```

Pour le workflow complet avec revue Git, commit et push :

- voir `docs/update-workflow.md`

## Hosts

- `main` : base desktop + profil dev + reseau (Tailscale + WARP)
- `laptop` : base desktop + profil dev + reseau
- `gaming` : base desktop + profil gaming + reseau

## Roles gaming et AI local

Deux roles utilisateur sont disponibles en plus de la base desktop :

| Role | Profil | Contenu |
|---|---|---|
| Gaming | `profiles/gaming.nix` | Steam + Proton, Lutris, Bottles (Battle.net), mangohud, gamescope, gamemode |
| AI local | `profiles/ai.nix` | ollama, llama-cpp, Flatpak (AnythingLLM Desktop) |

Ces roles sont **locaux et orientés utilisateur** — pas de services réseau partagés.

Pour le rôle AI : `workstation/ai` (local) est distinct de `homelab/ai-server` (service mutualisé). Voir `docs/ai.md`.

Voir `docs/gaming.md` et `docs/ai.md` pour les détails.
