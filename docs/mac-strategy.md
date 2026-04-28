# Stratégie macOS : Nix → Homebrew → MAS

## Aperçu

Sur `mac-mini`, les applications sont réparties entre trois écosystèmes.
Chaque couche a un rôle précis et une règle de priorité claire.

## Règle de priorité

Pour chaque application :

1. **Si elle est dans Nix** → utiliser `pkgs.<app>` ou un package personnalisé dans `systems/`
   - gestionnaire de dépendances via Nix
   - reproducible builds
   - intégration avec Home Manager
   - exemples : VS Code, Node, Rust toolchain, Nix itself

2. **Si elle n'existe pas dans Nix, ou que le package Nix est immature** → Homebrew
   - fallback pratique pour les apps avec peu de support Nix
   - outils généraux du quotidien
   - gestion manuelle des casks
   - exemple : Slack, Discord, Zoom

3. **Pour les apps natives macOS (Swift, SwiftUI)** → MAS
   - sandboxing natif Apple
   - certificats de sécurité gérés par Apple
   - mises à jour automatiques
   - exemples : Messages, Maps, Photos, tout ce que gère M

## Catalogue

### Nix (`pkgs.<app>`)

| App | Justification |
|-----|--------------|
| `nursery` | C'est Nix |
| `nodejs` | Mature Nix package |
| `vscode` | Mature Nix package, int intégré |
| `wasmtime` | Runtime RUST mature |
| `cargo` | Rust toolchain |
| `rust-analyzer` | Mature Nix package |
| `llvm` | Toolchain compilateur |
| `py3.*` | Python packages via Nix |
| `git` | Mature |
| `wget`, `curl` | Mature |

### Homebrew

| App | Justification |
|-----|--------------|
| `slack` | Non mature dans Nix |
| `zoom` | Cask non supporté Nix |
| `discord` | Non mature |
| `firefox` | Support Nix récent, cask disponible |
| `spotify` | Cask, non mature |
| `1password` | Cask natif, gestion simple |

### MAS (Mac App Store)

| App | Justification |
|-----|--------------|
| `messages` | App native macOS |
| `maps` | App native macOS |
| `photos` | App native macOS |
| `calculator` | App native macOS |
| `notes` | App native macOS |
| `app store` | Meta, gestion mise à jour |

## Configuration

### Home Manager

```nix
home.sessionVariables = {
  HOMEBREW_NO_INSTALL_CLEANUP = "1";  # éviter cleanup après install
};

home.packages = with pkgs; [
  # Nix packages ici
  # ...
];

home.file.".gnupg/home-manager".symlinkTo = ~/Dotfiles/.gnupg/home-manager;
```

### Nix Homebrew Integration

Le module `nix-homebrew` dans `flake.nix` permet d'utiliser Homebrew
dans le profil Nix. Cela permet :

```nix
home.useNixHomebrew = true;
```

Les packages Homebrew sont ajoutés à `home.packages` via
`nix-homebrew.users.<user>.brew`.

## Maintenance

### Ajouter un package Nix

```bash
nix shell nixpkgs#<app-name>
# tester
# if OK, commit dans le profil correspondant
```

### Ajouter un cask Homebrew

```bash
brew install --cask <app-name>
# ajouter dans home/roles/<role>.nix ou home/targets/<host>.nix
```

### S'assurer que MAS est utilisé pour les apps Apple

1. Vérifier que l'app n'est pas installée via Homebrew
2. Retirer de Homebrew si déjà installé
3. Installer depuis MAS

## Limites

### Nix Homebrew

- Casks ne supportent pas tous les apps Apple
- Certaines apps peuvent nécessiter des versions spécifiques
- Gestion des conflits de versions limitée

### MAS

- Sandboxing strict
- Certificats de sécurité gérés Apple
- Moins de contrôle sur les mises à jour

### macOS SDK

- Les apps natives nécessitent de compiler le SDK macOS
- Cela peut compliquer le développement d'applications natives

## Voir aussi

- `targets/hosts/mac-mini/config/capabilities.nix` — mapping des apps
- `home/targets/mac-mini.nix` — binding final
- `systems/` — modules Nix partagés
