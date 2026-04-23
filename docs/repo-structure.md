# Repo structure

Ce repo est désormais traité conceptuellement comme `infra` :
une seule base pour les briques système, les machines, la composition utilisateur,
les dotfiles, les services et les secrets.

## Structure retenue

- `modules/` : briques Nix réutilisables
- `targets/` : cibles concrètes
  - `targets/hosts/` : machines réelles
- `home/` : composition Home Manager users / roles / targets
- `dotfiles/` : bibliothèque de fichiers applicatifs réutilisables
- `stacks/` : services/applications portés par le repo
- `secrets/` : secrets chiffrés avec `sops-nix`
- `docs/` : documentation
- `scripts/` : orchestration légère et validation

## Règles de placement

### `modules/`
Contient des briques réutilisables :
- modules système
- profils réutilisables
- devshells
- sécurité / intégrations transverses
- templates

### `targets/`
Contient la réalité des machines :
- un host concret dans `targets/hosts/<name>/`
- ses variables machine
- sa config NixOS
- éventuellement son layout disque

### `home/`
Contient la composition utilisateur :
- `home/users/` = identité d'un user
- `home/roles/` = rôles composables
- `home/targets/` = binding final par machine

### `dotfiles/`
Contient uniquement du contenu brut applicatif.
Le choix de qui consomme quoi se fait dans `home/`.

### `stacks/`
Contient les services et applications portés par le repo `infra`.
Une stack peut être importée par un profil système, mais elle ne décide jamais quelle machine l'utilise.
