# stacks/openclaw/

Stack applicative OpenClaw portée par ce repo `infra`.

## Rôle

Cette stack décrit le socle applicatif OpenClaw :
- point d’activation NixOS : `infra.stacks.openclaw.enable`
- répertoires hôte attendus pour la suite :
  - `/etc/openclaw`
  - `/var/lib/openclaw`
  - `/var/log/openclaw`

À ce stade, la stack ne prétend pas définir tout le runtime OpenClaw.
Elle prépare proprement le terrain sans simuler un service complet non encore
spécifié.

## Frontière

- `targets/hosts/openclaw-vm/` = machine concrète dédiée à OpenClaw
- `modules/profiles/virtual-machine.nix` = contexte VM réutilisable
- `stacks/openclaw/` = socle de la stack OpenClaw

La stack ne décide jamais :
- quelle machine la porte
- si cette machine est bare metal ou VM
- quel layout disque ou quel firmware utiliser
