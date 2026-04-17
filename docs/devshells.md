# DevShells

## Philosophie

Les devShells de `workstation` sont locaux et orientés poste de travail personnel.

Règle de séparation :
- `foundation` — shells génériques et partagés (outillage serveur, CI, scripts infra)
- `workstation` — shells de productivité développeur, spécifiques au poste utilisateur

Un shell qui dépend d'un IDE, de Docker Desktop, ou de tooling personnel n'a pas sa place dans `foundation`.

## Shell .NET — `devShells.dotnet`

Commande :

```bash
nix develop .#dotnet
```

Définition : `devshells/dotnet.nix`.

Ce shell est **local à `workstation`**. Il n'est pas consommé depuis `foundation` et ne doit pas y migrer.

Contenu actuel :

- `dotnet-sdk`
- `git`
- `curl`
- `jq`
- `openssl`
- `pkg-config`
- `docker-client`

Vocation : environnement de développement principal du poste. À terme, ce shell accueillera Rider, WebStorm, et les outils de dev web/local si nécessaire.

## Étendre le shell .NET

Ajouter des outils dans `devshells/dotnet.nix` directement, dans la liste `packages`.

Exemples d'extensions futures :

```nix
jetbrains.rider
jetbrains.webstorm
nodejs
```

## Ajouter un nouveau devShell

1. Créer `devshells/<nom>.nix`
2. L'exposer dans `flake.nix` via `devShells.<system>.<nom>`
3. Documenter son usage dans ce fichier

## Quand passer un shell dans `foundation`

Uniquement si le shell est :
- générique (pas de tooling utilisateur ou IDE)
- utile sur des machines serveur ou CI
- stable et clairement délimité

Un shell de productivité personnelle reste dans `workstation`.
