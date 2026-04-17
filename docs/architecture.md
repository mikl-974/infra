# Architecture du repo `workstation`

## Philosophie

`workstation` est dédié aux environnements utilisateur (desktop, dotfiles, devShells), avec une architecture modulaire et multi-machines.

Ce repo est volontairement séparé de `homelab` :

- `workstation` = machines utilisateur
- `homelab` = serveurs et infrastructure

## Modèle de composition

1. `hosts/` décrit une machine réelle
2. chaque host importe un ou plusieurs `profiles/`
3. les profils assemblent des `modules/` ciblés
4. les dotfiles restent découplés dans `dotfiles/`
5. les environnements de dev sont dans `devshells/`

## Évolution multi-machines

La structure est prête pour `main`, `laptop`, `gaming` sans changer le layout :

- ajouter un host = nouveau dossier dans `hosts/<name>/`
- factoriser ce qui est commun en `profiles/`
- isoler la logique technique réutilisable dans `modules/`

## Extension propre

- ajouter des modules petits et ciblés
- éviter la logique implicite dans les hosts
- documenter chaque nouvelle brique fonctionnelle dans `docs/`
