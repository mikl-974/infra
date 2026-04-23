# targets/hosts/

Machines réelles gérées par ce repo.

Chaque dossier contient la vérité d’une machine donnée.

## Structure typique

### NixOS
- `vars.nix` : variables machine opératoires
- `default.nix` : entrée du host
- `config/` : responsabilités machine lisibles quand le host le justifie
- `disko.nix` : layout disque seulement si le host est réellement prévu pour NixOS Anywhere

### Darwin
- `vars.nix` : variables machine opératoires
- `default.nix` : entrée du host
- `config/` : responsabilités machine Darwin
