# secrets/

Secrets chiffrés du repo `infra`.

## Décision

La stratégie retenue est `sops-nix`.

## Fondation posée

- input flake `sops-nix`
- module réutilisable `modules/security/sops.nix`
- activation côté host via `infra.security.sops.enable = true;`
- clé Age attendue par défaut dans `/var/lib/sops-nix/key.txt`

## Règles

- ne jamais committer de secret en clair
- stocker ici les fichiers chiffrés SOPS quand ils existeront
- référencer les secrets depuis les hosts/profils explicitement
