# targets/

Cibles concrètes portées par le repo `infra`.

## Structure

- `targets/hosts/` = machines réelles
- `targets/README.md` = frontière et conventions

## Règle

`targets/` contient uniquement :
- la réalité machine
- la config machine
- le layout disque si nécessaire
- la logique de bootstrap / installation liée à cette machine

Il ne contient jamais :
- des briques réutilisables
- des stacks applicatives génériques
- de la composition Home Manager utilisateur

## Hosts actuels

- `main`
- `laptop`
- `gaming`
- `ms-s1-max`

## Ajouter une machine

1. créer `targets/hosts/<name>/vars.nix`
2. créer `targets/hosts/<name>/default.nix`
3. ajouter `disko.nix` si nécessaire
4. exposer la machine dans `flake.nix`
