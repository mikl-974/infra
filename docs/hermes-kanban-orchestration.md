# Hermes Kanban orchestration

## Role du host

`ms-s1-max` est le moteur permanent Hermes:

- il execute `hermes gateway run --replace` via `hermes-gateway.service`;
- il heberge `HERMES_HOME=/home/mfo/.hermes`;
- il heberge le Kanban SQLite (`kanban.db`) et les boards;
- il heberge les profiles Hermes et lance les workers a la demande.

Le Mac mini reste un poste client et de pilotage. Sa configuration utilisateur
Hermes est geree par Home Manager via `home/targets/mac-mini.nix`. Il se
connecte au serveur par SSH avec l'alias `hermes-backend`. Il ne doit pas
devenir le serveur Hermes principal, ne doit pas lancer de gateway local, et ne
doit pas utiliser un `kanban.db` local.

## Architecture NixOS

Le module reutilisable bas niveau est `systems/apps/hermes-agent.nix`. Le
module serveur, destine uniquement a `ms-s1-max`, est
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

Le service force `API_SERVER_HOST=127.0.0.1`. Si le serveur API Hermes
OpenAI-compatible est active plus tard via `API_SERVER_KEY` ou
`API_SERVER_ENABLED`, il reste donc lie a loopback par defaut. L'acces distant
doit passer par SSH ou par un tunnel SSH authentifie.

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

## Mac mini client

La configuration Darwin branche Home Manager dans `flake.nix`, puis importe la
composition `home/targets/mac-mini.nix` pour l'utilisateur `mickael`. Cette
composition active le module `home/modules/hermes-client.nix`.

Ce module:

- installe la CLI Hermes et OpenSSH dans le profil Home Manager;
- ajoute `~/.ssh/config` avec le host `hermes-backend` vers `ms-s1-max` et
  `User mfo`;
- ajoute les aliases zsh `hermes-remote`, `hermes-gateway-status` et
  `hermes-home`;
- ne declare aucun LaunchAgent, LaunchDaemon ou service Hermes local;
- ne definit pas `HERMES_HOME` et ne cree pas `~/.hermes`.

Les aliases exposes sur le Mac:

```bash
hermes-remote
hermes-gateway-status
hermes-home
```

Pour lancer Hermes sur le backend depuis le Mac:

```bash
hermes-remote -p tech-lead chat
ssh hermes-backend 'HERMES_HOME=/home/mfo/.hermes hermes kanban boards list'
```

TODO: Hermes expose un backend de terminal SSH (`terminal.backend: ssh`), mais
le code local verifie ne montre pas d'option de CLI client qui delegue
transparentement tout `HERMES_HOME`/Kanban vers un backend distant. Si Hermes
ajoute un transport officiel de backend distant, remplacer les aliases SSH par
cette option documentee.

## Ollama Mac mini

Le Mac mini expose Ollama via le module Darwin
`systems/apps/ollama-darwin.nix`, active depuis
`targets/hosts/mac-mini/config/capabilities.nix`.

Le service launchd utilisateur lance:

```bash
ollama serve
```

avec:

```bash
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_KEEP_ALIVE=10m
OLLAMA_MAX_LOADED_MODELS=1
OLLAMA_NUM_PARALLEL=1
```

L'usage attendu est l'acces par Tailscale/MagicDNS depuis `ms-s1-max`:

```bash
curl http://mac-mini:11434/api/tags
curl http://mac-mini:11434/v1/models
```

Comme `OLLAMA_HOST=0.0.0.0:11434`, garder l'exposition effective limitee a la
tailnet avec la politique Tailscale et/ou le pare-feu macOS. Ne pas publier ce
port sur Internet.

Le backend Hermes declare le provider custom:

```yaml
name: mac-mini/ollama-gemma4
base_url: http://mac-mini:11434/v1
model: gemma4
```

Le tag `gemma4` doit correspondre a la sortie de `ollama list` sur le Mac mini.
Si le tag local est different, ajuster `macMiniGemmaModel` dans
`targets/hosts/ms-s1-max/config/hermes-agent.nix`.

Un profile Hermes dedie est disponible:

```bash
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes -p gemma4-mac-mini chat
```

Verification cote Mac:

```bash
launchctl list | grep -i ollama || true
curl http://127.0.0.1:11434/api/tags
ollama list
```

Verification cote backend:

```bash
curl http://mac-mini:11434/api/tags
sudo -u mfo env HOME=/home/mfo HERMES_HOME=/home/mfo/.hermes hermes -p gemma4-mac-mini -z "reponds juste OK"
```

## Nettoyage manuel du Mac

Ces commandes sont a executer sur le Mac mini si une ancienne installation
locale Hermes existe. Elles ne sont pas automatisees par Nix pour eviter de
supprimer des donnees utilisateur.

Verifier qu'aucun service local ne tourne:

```bash
pgrep -af 'hermes.*gateway|hermes-gateway' || true
launchctl list | grep -i hermes || true
sudo launchctl list | grep -i hermes || true
```

Desactiver un ancien LaunchAgent/LaunchDaemon si present:

```bash
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/*hermes*.plist 2>/dev/null || true
sudo launchctl bootout system /Library/LaunchDaemons/*hermes*.plist 2>/dev/null || true
```

Supprimer uniquement les plists apres inspection:

```bash
ls -la ~/Library/LaunchAgents/*hermes*.plist /Library/LaunchDaemons/*hermes*.plist 2>/dev/null || true
```

Si un `~/.hermes` local existe et n'est plus voulu comme backend, le renommer en
backup date:

```bash
test -d ~/.hermes && mv ~/.hermes ~/.hermes.backup.$(date +%Y%m%d-%H%M%S)
```

Verifier que le Mac ne possede plus de backend Hermes local:

```bash
test ! -e ~/.hermes/kanban/kanban.db
pgrep -af 'hermes.*gateway|hermes-gateway' || true
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
