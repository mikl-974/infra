# Hermes Kanban orchestration

## Role du host

`ms-s1-max` est le moteur permanent Hermes:

- il execute `hermes gateway start` via `hermes-gateway.service`;
- il heberge `HERMES_HOME=/home/mfo/.hermes`;
- il heberge le Kanban SQLite (`kanban.db`) et les boards;
- il heberge les profiles Hermes et lance les workers a la demande.

Le Mac mini reste un poste client et de pilotage. Il se connecte au serveur
par SSH, par l'UI Hermes exposee par le gateway si elle est active, ou par une
CLI distante selon les transports Hermes disponibles. Il ne doit pas devenir le
serveur Hermes principal.

## Architecture NixOS

Le module reutilisable est `systems/apps/hermes-agent.nix`. L'activation et la
configuration concrete de `ms-s1-max` sont dans
`targets/hosts/ms-s1-max/config/hermes-agent.nix`.

Options principales:

- `homelab.services.hermes.enable`
- `homelab.services.hermes.user`
- `homelab.services.hermes.home`
- `homelab.services.hermes.binary`
- `homelab.services.hermes.gateway.enable`
- `homelab.services.hermes.workspaces.enable`
- `homelab.services.hermes.workspaces.root`
- `homelab.services.hermes.desktop.enable`
- `homelab.services.hermes.kanban.dispatchInGateway`
- `homelab.services.hermes.extraEnvironment`
- `homelab.services.hermes.settings`
- `homelab.services.hermes.profiles`

Sur `ms-s1-max`, le service utilise:

```bash
HOME=/home/mfo
HERMES_HOME=/home/mfo/.hermes
HERMES_KANBAN_WORKSPACES_ROOT=/home/mfo/.hermes/kanban/workspaces
```

Le chemin du binaire Hermes est declare par option Nix. Le host pointe
actuellement vers le package `hermes-agent` du flake. Pour une installation
hors Nix, remplacer `homelab.services.hermes.binary` par un chemin comme
`/home/mfo/.local/bin/hermes`.

Aucun token ni secret n'est declare par ce module. Les secrets Hermes restent
dans les mecanismes Hermes existants ou dans SOPS si une future integration Nix
en consomme explicitement.

La configuration locale Hermes a ete reprise de `~/.hermes` sous forme
declarative pour les elements non secrets:

- `config.yaml` racine;
- providers homelab, adaptes pour `ms-s1-max` avec `127.0.0.1`;
- sections non secretes de messagerie (`matrix`, `whatsapp`, `telegram`,
  `discord`, `slack`, `platforms`, `platform_toolsets`);
- profiles `tech-lead`, `architecte`, `developer`, `tester`, `auditeur`,
  `doc-maintainer`, `prompt-engineer`;
- `profile.yaml`, `SOUL.md` et `config.yaml` des profiles.

Les fichiers runtime suivants ne sont pas geres par Nix et ne doivent pas etre
commites:

- `.env`;
- `auth.json` et fichiers OAuth;
- `state.db`, sessions et caches;
- `whatsapp/session/*`;
- `platforms/matrix/*` si des credentials y sont stockes.

## Gateway et Kanban

Le service permanent est le Gateway, pas une session interactive du type
`hermes -p <profile> chat`.

Kanban sert de bus de communication entre profiles. Les humains et les scripts
creent ou inspectent des cartes avec `hermes kanban ...`; les agents lisent et
mettent a jour les cartes par les outils `kanban_*` fournis aux workers. Le
dispatcher tourne dans le Gateway avec:

```yaml
kanban:
  dispatch_in_gateway: true
```

Le module force aussi cette posture dans l'environnement du service avec
`HERMES_KANBAN_DISPATCH_IN_GATEWAY=true` quand
`homelab.services.hermes.kanban.dispatchInGateway = true`.

La racine des workspaces Kanban est explicite sur `ms-s1-max` via
`homelab.services.hermes.workspaces.enable = true`. Par defaut elle suit
`HERMES_HOME` et vaut `/home/mfo/.hermes/kanban/workspaces`. Elle est creee
avec les droits de `mfo` et exposee au Gateway avec
`HERMES_KANBAN_WORKSPACES_ROOT`.

Ne pas lancer `hermes kanban daemon` en parallele du Gateway sur le meme
`kanban.db`. Si plusieurs gateways Hermes sont ajoutes plus tard, un seul doit
avoir `dispatch_in_gateway: true`; tous les autres doivent utiliser:

```yaml
kanban:
  dispatch_in_gateway: false
```

ou l'equivalent Nix:

```nix
homelab.services.hermes.kanban.dispatchInGateway = false;
```

## Profiles

Le routing d'orchestration se fait par role et par nom de profile, pas par nom
de modele. Le modele reste une propriete de chaque profile Hermes.

- `tech-lead`: point d'entree humain, decomposition, creation et assignation
  des cartes, suivi, synthese.
- `architecte`: conception technique, arbitrages structurants, analyse
  d'architecture.
- `developer`: implementation, refactoring, scripts, corrections.
- `tester`: tests, reproduction, validation.
- `auditeur`: revue securite, coherence, maintenabilite, analyse de risque.
- `doc-maintainer`: README, documentation, changelog, instructions.
- `prompt-engineer`: prompts, consignes agents, workflows IA.

## Commandes de diagnostic

Verifier le service:

```bash
systemctl status hermes-gateway.service
journalctl -u hermes-gateway.service -f
```

Verifier les profiles et Kanban:

```bash
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes profile list
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes kanban list
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes kanban boards list
```

Si Hermes est installe hors Nix:

```bash
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes /home/mfo/.local/bin/hermes profile list
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes /home/mfo/.local/bin/hermes kanban list
```

Lancer le profile d'orchestration manuellement:

```bash
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes -p tech-lead chat
```

Verifier les profiles declaratifs:

```bash
sudo -u mfo test -f /home/mfo/.hermes/profiles/tech-lead/SOUL.md
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes profile list
```

Verifier le launcher Desktop:

```bash
command -v hermes-desktop
hermes-desktop
```

Verifier la racine workspaces:

```bash
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes HERMES_KANBAN_WORKSPACES_ROOT=/home/mfo/.hermes/kanban/workspaces hermes kanban boards show
ls -ld /home/mfo/.hermes/kanban/workspaces
```

Verifier qu'un seul dispatcher possede le board:

```bash
systemctl status hermes-gateway.service
systemctl status hermes-kanban-dispatcher.service
pgrep -af 'hermes.*kanban.*daemon|hermes.*gateway start'
```

`hermes-kanban-dispatcher.service` doit etre absent ou arrete quand le Gateway
embarque le dispatcher. Le module Nix declare aussi un conflit systemd avec ce
service autonome pour eviter un double demarrage local.

## Validation Nix

Evaluation du host:

```bash
nix eval .#nixosConfigurations.ms-s1-max.config.system.build.toplevel.drvPath
```

Validation globale du repo:

```bash
nix flake check
```
