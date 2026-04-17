# DevShells

## Pourquoi ici

Les devShells sont versionnés dans `workstation` pour garantir des environnements de développement reproductibles sur les machines utilisateur.

## Shell .NET

Commande :

```bash
nix develop .#dotnet
```

Définition : `devshells/dotnet.nix`.

Contenu minimal :

- `dotnet-sdk`
- `git`
- `curl`
- `jq`
- `openssl`
- `pkg-config`

## Ajouter un nouveau devShell

1. créer `devshells/<nom>.nix`
2. l’exposer dans `flake.nix` via `devShells.<system>.<nom>`
3. documenter son usage dans ce dossier `docs/`
