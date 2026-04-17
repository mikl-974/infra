# DevShells

## Pourquoi ici

Les devShells sont exposés dans `workstation` pour garantir un accès cohérent sur toutes les machines utilisateur. Les shells génériques sont fournis par `foundation` — `workstation` les consomme sans les dupliquer.

## Shell .NET

Commande :

```bash
nix develop .#dotnet
```

Source : `foundation.devShells.<system>.dotnet`.

Aucune définition locale — si `foundation` met à jour le shell, `workstation` hérite automatiquement de la mise à jour lors du prochain `nix flake update`.

Contenu (défini dans `foundation/nix/devshells/dotnet.nix`) :

- `dotnet-sdk`
- `git`
- `curl`
- `jq`
- `openssl`
- `pkg-config`

## Étendre le shell .NET localement

Si `workstation` a besoin d'outils supplémentaires spécifiques au poste, ne pas modifier `foundation`.

Dans `flake.nix`, composer localement :

```nix
devShells = lib.genAttrs systems (system: {
  dotnet = pkgs.mkShell {
    inputsFrom = [ foundation.devShells.${system}.dotnet ];
    packages = with (import nixpkgs { inherit system; }); [
      # outil workstation-specifique
    ];
  };
});
```

## Ajouter un nouveau devShell workstation-spécifique

1. Si le shell est générique → l'ajouter dans `foundation`
2. Si le shell est spécifique au poste de travail → l'exposer directement dans `flake.nix`
3. Documenter son usage dans ce fichier

## Consommer un autre devShell depuis `foundation`

Si `foundation` expose un nouveau shell (ex: `rust`, `python`), l'ajouter dans `flake.nix` :

```nix
devShells = lib.genAttrs systems (system: {
  dotnet = foundation.devShells.${system}.dotnet;
  rust   = foundation.devShells.${system}.rust;  # si disponible
});
```
