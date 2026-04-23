# targets/

Machines concretes gérées par ce repo.

## Règle

Ce dossier contient uniquement :
- des hosts réels (machines physiques ou VMs)
- leur configuration machine (`default.nix`)
- leur layout disque (`disko.nix`) si applicable
- leurs variables machine (`vars.nix`)

Il ne contient jamais :
- de modules réutilisables
- de stacks applicatives
- de logique générique transverse

## Ajouter une nouvelle machine

1. Créer `targets/<name>/vars.nix` depuis le template :
   ```bash
   cp modules/templates/host-vars.nix targets/<name>/vars.nix
   # éditer targets/<name>/vars.nix
   ```
2. Créer `targets/<name>/default.nix` en composant des profils depuis `modules/profiles/`
3. Ajouter le host dans `flake.nix` avec `mkHost`
4. Valider : `nix run .#validate-install -- <name>`

## Machines actuelles

| Machine | Profils | Usage |
|---|---|---|
| `main` | desktop-hyprland, dev, networking | poste de travail principal |
| `laptop` | desktop-hyprland, dev, networking | machine portable |
| `gaming` | desktop-hyprland, gaming, networking | machine gaming |
