# home/

Composition de la configuration utilisateur.

## Rôle

Ce dossier orchestre le binding entre :
- users (profil Home Manager d'un utilisateur concret)
- roles (jeux d'options pour un usage ou un rôle)
- targets (overrides spécifiques à une machine)

## Structure

| Dossier | Rôle |
|---|---|
| `home/users/` | Configuration Home Manager par utilisateur |
| `home/roles/` | Compositions de rôles réutilisables (placeholder) |
| `home/targets/` | Overrides spécifiques à une machine (placeholder) |

## Extension

Pour ajouter un second utilisateur :
1. Créer `home/users/<username>.nix`
2. Le référencer dans `flake.nix` via `home-manager.users.<username>`

Pour ajouter des overrides par target :
1. Créer `home/targets/<name>.nix`
2. L'importer conditionnellement depuis le host via `specialArgs`
