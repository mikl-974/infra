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
- Hyprland et la base desktop : specifique machines utilisateur
- Cloudflare WARP : client VPN desktop, pas une primitive infra
- Solaar / Bluetooth / Wi-Fi desktop : integration locale des peripheriques et applets utilisateur
- Noctalia : theme et identite visuelle du poste
- Editeurs / IDE (VS Code, Rider, WebStorm) : applications desktop dev
- theming, dotfiles, profils desktop, configuration utilisateur

## Separation desktop / utilities / dev / gaming / ai / shell

| Couche | Localisation | Ce qu'elle contient |
|---|---|---|
| Base desktop | `profiles/desktop-hyprland.nix` | Hyprland, terminal, launcher, audio, Noctalia, WARP, Bluetooth, Wi-Fi |
| Utilities desktop | `modules/apps/utilities.nix` + `modules/desktop/connectivity.nix` | Solaar, nm-applet, Blueman, pavucontrol, brightnessctl, playerctl |
| Dev utilisateur | `profiles/dev.nix` | IDE (VS Code, Rider, WebStorm), outils CLI dev systeme |
| Gaming | `profiles/gaming.nix` | Steam, Proton, Lutris, Bottles, mangohud, gamescope, gamemode |
| AI local | `profiles/ai.nix` | ollama, llama-cpp, Flatpak (AnythingLLM Desktop) |
| Shell dev | `devshells/dotnet.nix` | SDK .NET, Docker CLI, playwright, outils CLI |

Les editeurs / IDE sont des applications desktop installes en tant que paquets systeme.
Ils ne vivent pas dans un devShell.
Le devShell fournit les runtimes et outils CLI avec lesquels les editeurs travaillent.

## Modele de composition

1. `hosts/` decrit une machine reelle
2. chaque host importe un ou plusieurs `profiles/`
3. les profils assemblent des `modules/roles/` (composition apps + config systeme)
4. les roles importent des `modules/apps/` (paquets) et configurent les options systeme
5. les dotfiles restent decouples dans `dotfiles/`
6. les environnements de dev CLI sont definis localement dans `devshells/`
7. la configuration utilisateur est geree par Home Manager (`home/default.nix`)

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
hosts/                machines concretes
  main/
    default.nix       configuration host (profils, hostname, boot)
    disko.nix         layout disque (GPT + EFI + btrfs)
  laptop/
  gaming/
profiles/             assemblages de roles reutilisables
  desktop-hyprland.nix  base graphique (Hyprland, Noctalia, WARP, connectivite locale, utilities)
  dev.nix               outils dev utilisateur (IDE, CLI systeme)
  networking.nix        reseau (Tailscale)
  gaming.nix            profil gaming (Steam, Lutris, gamemode)
  ai.nix                profil AI local (ollama, llama-cpp, Flatpak)
modules/              logique Nix isolee par domaine
  desktop/            Hyprland, audio, connectivity, portals, fonts, WARP
  theming/            Noctalia et theming systeme
  apps/
    default.nix       apps desktop generiques
    utilities.nix     utilitaires desktop quotidiens
    editors.nix       IDE (VS Code, Rider, WebStorm)
    gaming.nix        apps gaming (Lutris, Bottles, mangohud, gamescope, wine)
    ai.nix            apps AI local (ollama, llama-cpp)
  roles/
    gaming.nix        role gaming (programs.steam, programs.gamemode + apps/gaming)
    ai.nix            role AI local (Flatpak + apps/ai)
  shell/              configuration shell systeme
devshells/            environnements de dev CLI locaux
  dotnet.nix          shell .NET (SDK, Docker CLI, playwright)
home/                 configuration Home Manager (utilisateur)
  default.nix         dotfiles, xdg, paquets utilisateur
dotfiles/             configurations applicatives brutes
  hypr/               Hyprland
  foot/               terminal
  wofi/               launcher
  shell/              shell
  noctalia/           theme Noctalia (palette, assets)
  editors/            editeurs (VS Code, Rider)
docs/                 documentation
```

## Evolution multi-machines

La structure est prete pour `main`, `laptop`, `gaming` sans changer le layout :

- ajouter un host = nouveau dossier dans `hosts/<name>/`
- factoriser ce qui est commun en `profiles/`
- isoler la logique technique reutilisable dans `modules/`

## Quand une brique doit rester dans `workstation`

Une brique reste dans `workstation` si elle est :

- liee au bureau/utilisateur (Hyprland, theming, WARP)
- trop specifique au poste de travail pour etre partagee utilement
- pas encore testee dans d'autres contextes

Une brique passe dans `foundation` si elle est :

- generique (networking, securite de base, users)
- utilisable sur des serveurs comme sur des postes
- stable et clairement delimitee

## Extension propre

- ajouter des modules petits et cibles dans `modules/`
- pour un nouveau role : creer `modules/apps/<role>.nix` + `modules/roles/<role>.nix` + `profiles/<role>.nix`
- factoriser les comportements communs en `profiles/`
- consommer `foundation` via l'input flake, pas via copie locale
- documenter chaque nouvelle brique fonctionnelle dans `docs/`

## Couche roles (modules/roles/)

La couche `modules/roles/` est intermediaire entre `modules/apps/` et `profiles/` :

- `modules/apps/<role>.nix` : paquets et applications uniquement
- `modules/roles/<role>.nix` : composition (imports apps + configuration systeme liee a l'usage)
- `profiles/<role>.nix` : point d'entree simple pour les hosts

Un host importe des profils. Un profil importe un ou plusieurs roles. Un role importe des apps et configure le systeme.

## Utilities desktop et connectivite locale

La workstation contient une couche utilitaire desktop volontairement locale :

- `modules/apps/utilities.nix` -> paquets utilitaires utilisateur
- `modules/desktop/connectivity.nix` -> Wi-Fi, Bluetooth, Solaar et applets desktop

Cette couche reste dans `workstation` parce qu'elle gere :

- des applets et outils relies a une session desktop
- des peripheriques locaux
- des integrations utilisateur-machine

Elle ne doit pas etre extraite vers `foundation` tant qu'elle n'est pas generique et multi-contexte.

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
