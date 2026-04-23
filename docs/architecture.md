# Architecture du repo `infra`

## Principe

Le repo Git s'appelle encore `workstation`, mais son rôle cible est `infra`.
Il porte maintenant ensemble :
- machines NixOS
- machines Darwin
- users
- rôles Home Manager
- dotfiles
- stacks
- secrets

## Frontières

| Couche | Rôle | Exemple |
|---|---|---|
| `modules/` | briques réutilisables | profiles, security, darwin |
| `targets/hosts/` | réalité machine | `ms-s1-max`, `macmini` |
| `home/users/` | identité d’un user | `mfo.nix`, `dfo.nix` |
| `home/roles/` | binding réutilisable par usage | `desktop-hyprland.nix`, `terminal-kitty.nix` |
| `home/targets/` | composition finale par machine | `ms-s1-max.nix` |
| `dotfiles/` | contenu brut réutilisable | Hyprland, Kitty, GTK |
| `stacks/` | services/applications | `ai-server/` |
| `secrets/` | source chiffrée | `secrets/hosts/ms-s1-max.yaml` |

## NixOS vs Darwin

Le repo distingue maintenant explicitement :
- `nixosConfigurations.*` pour les targets NixOS
- `darwinConfigurations.*` pour les targets Darwin

Un target Darwin reste un target concret dans `targets/hosts/`.
Il ne devient pas un faux host NixOS.

## Darwin actuel

Le premier target Darwin modélisé est `macmini`.

### Base réutilisable
- `modules/darwin/base.nix` : base commune Darwin (`allowUnfree`, flakes, revision, stateVersion, hostPlatform)
- `modules/darwin/homebrew.nix` : activation Homebrew / nix-homebrew commune

### Spécifique machine
- `targets/hosts/macmini/config/user.nix` : user principal Darwin
- `targets/hosts/macmini/config/apps.nix` : paquets Nix + casks Homebrew
- `targets/hosts/macmini/config/networking.nix` : apps MAS réseau/VPN

### Principe d'installation
- Nix quand le package est proprement disponible sur Darwin
- Homebrew quand le bon adapter macOS est Homebrew
- MAS quand l'App Store est le canal pragmatique

## Secrets

Le premier flux réel branché utilise `sops-nix` pour `ms-s1-max` :
- le YAML chiffré vit dans `secrets/hosts/ms-s1-max.yaml`
- le host l'active via `infra.security.sops.defaultSopsFile`
- les hashes de mot de passe sont injectés vers `hashedPasswordFile`
- les bootstrap passwords sont matérialisés en root-only sous `/run/secrets/ms-s1-max/bootstrap/`

## Legacy

`home/users/default.nix` reste un fallback de compatibilité pour les anciens hosts NixOS.
Ce n'est pas le chemin recommandé pour les nouveaux bindings, et cela ne joue aucun rôle dans le target Darwin `macmini`.
