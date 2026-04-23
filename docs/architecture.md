# Architecture du repo `workstation`

## Philosophie

`workstation` est dedie aux environnements utilisateur (desktop, dotfiles, devShells), avec une architecture modulaire et multi-machines.

Ce repo est volontairement separe de `homelab` :

- `workstation` = machines utilisateur
- `homelab` = serveurs et infrastructure

Il consomme `foundation` comme socle partage sans en dependre structurellement.

## Relation avec `foundation`

`foundation` fournit des briques generiques reutilisables (modules NixOS, conventions).

Regle stricte :
- `foundation` ne connait pas `workstation`
- `workstation` importe `foundation` via input flake

Briques actuellement consommees depuis `foundation` :

- `foundation.nixosModules.networkingTailscale` — module Tailscale

Briques conservees dans `workstation` :

- devShell `.NET` : environnement CLI de dev personnel (Docker, playwright) — pas une brique generique
- Hyprland et la couche UX de premier login : specifique machines utilisateur
- Cloudflare WARP : client VPN desktop, pas une primitive infra
- Podman (usage profil dev local) : moteur de containers de poste utilisateur, pas modele ici comme primitive infra partagee
- Solaar / Bluetooth / Wi-Fi desktop : integration locale des peripheriques et applets utilisateur
- Daily apps desktop : applications quotidiennes de base (web, PDF, images, fichiers)
- Noctalia : theme et identite visuelle du poste
- Editeurs / IDE / apps dev desktop (VS Code, Rider, WebStorm, Neovim, GitKraken) : applications desktop dev
- theming, dotfiles, profils desktop, configuration utilisateur

## Separation desktop / daily / utilities / dev / gaming / ai / shell

| Couche | Localisation | Ce qu'elle contient |
|---|---|---|
| Base desktop | `modules/profiles/desktop-hyprland.nix` | Hyprland, terminal, launcher, audio, Noctalia, WARP, Bluetooth, Wi-Fi, daily apps, UX de session |
| Daily apps | `modules/apps/daily.nix` | Firefox, Chromium, Zathura, imv, Thunar, File Roller, LocalSend, cliphist, mako |
| Utilities desktop | `modules/apps/utilities.nix` + `modules/desktop/connectivity.nix` | Solaar, nm-applet, Blueman, pavucontrol, brightnessctl, playerctl, nm-connection-editor |
| Dev utilisateur | `modules/profiles/dev.nix` | IDE / editeurs / apps dev (VS Code, Rider, WebStorm, Neovim, GitKraken), outils CLI dev systeme, Podman local |
| Gaming | `modules/profiles/gaming.nix` | Steam, Proton, Lutris, Bottles, mangohud, gamescope, gamemode |
| AI local | `modules/profiles/ai.nix` | ollama, llama-cpp, Flatpak (AnythingLLM Desktop) |
| Shell dev | `devshells/dotnet.nix` | SDK .NET, Docker CLI, playwright, outils CLI |

Les editeurs / IDE sont des applications desktop installes en tant que paquets systeme.
Ils ne vivent pas dans un devShell.
Le devShell fournit les runtimes et outils CLI avec lesquels les editeurs travaillent.

## Modele de composition

1. `targets/` decrit une machine reelle
2. chaque target importe un ou plusieurs `modules/profiles/`
3. les profils assemblent des `modules/roles/` (composition apps + config systeme)
4. les roles importent des `modules/apps/` (paquets) et configurent les options systeme
5. les dotfiles restent decouples dans `dotfiles/`
6. les environnements de dev CLI sont definis localement dans `devshells/`
7. la configuration utilisateur est geree par Home Manager (`home/default.nix`)
8. les fichiers applicatifs bruts actifs vivent dans `dotfiles/`

## Inputs flake

| Input | Role |
|---|---|
| `nixpkgs` | Packages NixOS |
| `foundation` | Modules NixOS partages (Tailscale) |
| `disko` | Partitionnement declaratif — requis pour NixOS Anywhere |
| `home-manager` | Gestion de la configuration utilisateur et des dotfiles |

## Structure des fichiers

```
flake.nix             point d'entree, inputs, nixosConfigurations, devShells
targets/              machines concretes
  main/
    default.nix       configuration machine (profils, hostname, boot)
    disko.nix         layout disque (GPT + EFI + btrfs)
    vars.nix          valeurs de la machine (username, disk, timezone…)
  laptop/
  gaming/
  README.md
modules/              logique Nix reutilisable par domaine
  modules/profiles/  assemblages reutilisables
    desktop-hyprland.nix  base graphique (Hyprland, Noctalia, WARP, daily apps)
    dev.nix               outils dev utilisateur (IDE, CLI systeme)
    networking.nix        reseau (Tailscale)
    gaming.nix            profil gaming (Steam, Lutris, gamemode)
    ai.nix                profil AI local (ollama, llama-cpp, Flatpak)
  devshells/          environnements de dev CLI locaux
    dotnet.nix        shell .NET (SDK, Docker CLI, playwright)
  templates/          templates de configuration
    host-vars.nix     template vars.nix pour nouvelle machine
  desktop/            Hyprland, audio, connectivity, portals, fonts, WARP
  theming/            Noctalia et theming systeme
  apps/
    default.nix       apps desktop generiques
    daily.nix         applications quotidiennes de base
    utilities.nix     utilitaires desktop quotidiens
    dev.nix           applications dev desktop (GitKraken)
    editors.nix       editeurs / IDE (Neovim, VS Code, Rider, WebStorm)
    gaming.nix        apps gaming (Lutris, Bottles, mangohud, gamescope, wine)
    ai.nix            apps AI local (ollama, llama-cpp)
  containers/         moteurs de containers locaux de dev
    podman.nix        podman local avec compatibilite Docker
  roles/
    gaming.nix        role gaming (programs.steam, programs.gamemode + apps/gaming)
    ai.nix            role AI local (Flatpak + apps/ai)
  shell/              configuration shell systeme
  README.md
stacks/               services et applications (placeholder — stacks serveur dans homelab)
  README.md
secrets/              secrets chiffres (placeholder)
  README.md
home/                 composition utilisateur
  users/
    default.nix       configuration Home Manager de l'utilisateur principal
  roles/              compositions de roles HM reutilisables (placeholder)
  targets/            overrides HM par machine (placeholder)
  README.md
dotfiles/             bibliotheque de configs applicatives par app/domaine
  hyprland/           Hyprland
  terminal/           Foot (terminal)
  launchers/          Wofi (lanceur)
  notifications/      Mako (notifications)
  themes/
    noctalia/         theme Noctalia (palette, assets)
  shell/              shell
  editors/            editeurs (VS Code, Rider)
  README.md
docs/                 documentation
scripts/              orchestration, validation, installation
```

## Evolution multi-machines

La structure est prete pour `main`, `laptop`, `gaming` sans changer le layout :

- ajouter un target = nouveau dossier dans `targets/<name>/`
- factoriser ce qui est commun en `modules/profiles/`
- isoler la logique technique reutilisable dans `modules/`

## Quand une brique doit rester dans `workstation`

Une brique reste dans `workstation` si elle est :

- liee au bureau/utilisateur (Hyprland, theming, WARP)
- liee a l'UX locale d'un poste de dev (Podman local, GitKraken, Neovim, browsers desktop)
- trop specifique au poste de travail pour etre partagee utilement
- pas encore testee dans d'autres contextes

Une brique passe dans `foundation` si elle est :

- generique (networking, securite de base, users)
- utilisable sur des serveurs comme sur des postes
- stable et clairement delimitee

## Extension propre

- ajouter des modules petits et cibles dans `modules/`
- pour un nouveau role : creer `modules/apps/<role>.nix` + `modules/roles/<role>.nix` + `modules/profiles/<role>.nix`
- factoriser les comportements communs en `modules/profiles/`
- consommer `foundation` via l'input flake, pas via copie locale
- documenter chaque nouvelle brique fonctionnelle dans `docs/`

## Couche roles (modules/roles/)

La couche `modules/roles/` est intermediaire entre `modules/apps/` et `modules/profiles/` :

- `modules/apps/<role>.nix` : paquets et applications uniquement
- `modules/roles/<role>.nix` : composition (imports apps + configuration systeme liee a l'usage)
- `modules/profiles/<role>.nix` : point d'entree simple pour les targets

Un target importe des profils. Un profil importe un ou plusieurs roles. Un role importe des apps et configure le systeme.

## Utilities desktop et connectivite locale

La workstation contient une couche utilitaire desktop volontairement locale :

- `modules/apps/daily.nix` -> applications quotidiennes de base
- `modules/apps/utilities.nix` -> paquets utilitaires utilisateur
- `modules/desktop/connectivity.nix` -> Wi-Fi, Bluetooth, Solaar et applets desktop

Cette couche reste dans `workstation` parce qu'elle gere :

- des applications purement liees a la vie quotidienne sur le bureau
- des applets et outils relies a une session desktop
- des peripheriques locaux
- des integrations utilisateur-machine

Elle ne doit pas etre extraite vers `foundation` tant qu'elle n'est pas generique et multi-contexte.

Frontieres retenues :

- `daily.nix` -> applications utilisateur courantes
- `utilities.nix` -> helpers techniques et petits outils systeme
- `dev.nix` -> applications desktop de developpeur qui ne sont pas des editeurs
- `connectivity.nix` -> integrations desktop/systeme liees au reseau et aux peripheriques
- `editors.nix` -> editeurs et IDE
- `containers/podman.nix` -> moteur de containers local du profil dev

## Frontiere modules / Home Manager / dotfiles

Regle retenue :

- `modules/` -> paquets, services, options systeme, activation des briques desktop
- `home/users/default.nix` -> declaration explicite des fichiers utilisateur actifs
- `dotfiles/` -> bibliotheque de configs applicatives par app/domaine (hyprland, terminal, launchers, notifications, themes…)
- `home/roles/` -> compositions de roles Home Manager reutilisables (placeholder)
- `home/targets/` -> overrides Home Manager par machine (placeholder)
- `scripts/` -> orchestration, diagnostic, validation et vérification ; jamais source de vérité

## Frontiere Cockpit / virtualisation

Cockpit n'appartient pas a `workstation`.

Raison :

- Cockpit est une UI web d'administration de host Linux
- la gestion de VMs via Cockpit depend d'un backend serveur (`libvirt`, `qemu`)
- cette responsabilite releve de `homelab`, pas d'un poste utilisateur

La decision detaillee est documentee dans `docs/tool-placement.md`.

Exemple concret :

- `modules/apps/daily.nix` installe `mako` et `cliphist`
- `dotfiles/hyprland/hyprland.conf` definit l'autostart et les bindings
- `dotfiles/notifications/config` definit le comportement du daemon de notifications
- `home/default.nix` lie ces fichiers dans `~/.config/`

## Distinction workstation/ai vs homelab/ai-server

Le role `ai` de `workstation` est strictement local :
- outils lances depuis la machine de l'utilisateur
- API sur localhost uniquement (pas d'exposition reseau)
- pas de service daemon partage

Le role `ai-server` dans `homelab` est un service mutualisé :
- expose une API sur le reseau local
- sert plusieurs machines
- tourne en tant que daemon systeme

Cette distinction est architecturale et non-négociable.
Voir `docs/ai.md` pour les détails.
