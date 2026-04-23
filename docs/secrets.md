# Flux secrets `sops-nix`

## Clé Age privée — stockage, backup et récupération

### Identité Age active

La clé publique Age déclarée dans `.sops.yaml` est :
```
age1j9nearzgw8k859r0re0r4uzejxr67sg5glfhnhrzuu5e5f63pyesyvdche
```
Elle est dérivée de la clé SSH Ed25519 du compte `mikl-974`.

### Où stocker la clé privée

Sur chaque machine qui doit déchiffrer des secrets, la clé privée doit être présente à :
```
/var/lib/sops-nix/key.txt   (chmod 600, propriétaire root)
```
Ce chemin est déclaré dans `modules/security/sops.nix` via `ageKeyFile`.

### Premier provisionnement (ou après perte)

```bash
# Dériver la clé Age depuis la clé SSH Ed25519 (à lancer une seule fois)
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > /tmp/age.key

# Installer sur la machine cible (ou localement)
sudo mkdir -p /var/lib/sops-nix
sudo install -m 600 -o root -g root /tmp/age.key /var/lib/sops-nix/key.txt
rm /tmp/age.key
```

### Backup de la clé

La clé Age dérive de la clé SSH. Tant que la clé SSH Ed25519 est sauvegardée (gestionnaire de mots de passe, coffre-fort chiffré, etc.), la clé Age peut être régénérée à la demande via `ssh-to-age`.

**Règle :** ne pas stocker la clé Age elle-même dans ce repo — elle se reconstruit depuis la clé SSH.

### Rotation de la clé

1. Générer une nouvelle paire SSH (ou utiliser une autre clé existante)
2. Dériver la nouvelle clé Age : `ssh-to-age -private-key -i ~/.ssh/new_key > new_age.key`
3. Extraire la clé publique : `age-keygen -y new_age.key`
4. Ajouter le nouveau recipient dans `.sops.yaml`
5. Re-chiffrer tous les fichiers secrets : `sops updatekeys secrets/hosts/ms-s1-max.yaml` (etc.)
6. Retirer l'ancien recipient de `.sops.yaml` si rotation complète
7. Supprimer l'ancienne clé privée sur les machines concernées

## Flux réellement branché

Host : `ms-s1-max`

### Source chiffrée
- fichier : `secrets/hosts/ms-s1-max.yaml`
- règle de chiffrement : `.sops.yaml`

### Déclaration
Dans `targets/hosts/ms-s1-max/default.nix` :
- `infra.security.sops.defaultSopsFile = ../../../secrets/hosts/ms-s1-max.yaml;`
- secrets déclarés via `sops.secrets.*`

### Injection runtime
- hashes utilisateurs : `/run/secrets-for-users/...`
- bootstrap passwords root-only : `/run/secrets/ms-s1-max/bootstrap/...`

### Consommation
- `users.users.mfo.hashedPasswordFile`
- `users.users.dfo.hashedPasswordFile`

## OpenClaw

La stack `stacks/openclaw/` consomme maintenant un premier secret réel :
- le token d’auth gateway, généré localement au premier start dans `/var/lib/openclaw/secrets/gateway-token.env`

Principe retenu :
- le repo ne commit aucun secret OpenClaw fictif
- le token d’auth nécessaire au gateway est créé sur la VM dédiée au premier start
- la stack locale peut toujours raccorder un fichier secret via `infra.stacks.openclaw.secrets.sopsFile`
- ce fichier alimente alors le service upstream `openclaw-gateway` comme `EnvironmentFile`

Secrets externes encore hors scope pour cette passe :
- token Telegram
- clés provider (`ANTHROPIC_API_KEY`, etc.)

Le bon emplacement retenu pour ces secrets externes, quand ils existeront, reste :
- `secrets/stacks/openclaw.yaml`

## Comment reproduire

### 1. Préparer l'identité Age
Depuis la clé SSH privée Ed25519 correspondant à la clé publique GitHub de `mikl-974` :

```bash
ssh-to-age -private-key -i ~/.ssh/id_ed25519 > /var/lib/sops-nix/key.txt
chmod 600 /var/lib/sops-nix/key.txt
```

### 2. Éditer le secret

```bash
sops secrets/hosts/ms-s1-max.yaml
```

### 3. Rebuild

```bash
sudo nixos-rebuild switch --flake .#ms-s1-max
```

### 4. Vérifier la consommation

```bash
sudo ls /run/secrets/ms-s1-max/bootstrap/
sudo cat /run/secrets/ms-s1-max/bootstrap/mfo-password
sudo cat /run/secrets/ms-s1-max/bootstrap/dfo-password
```

## Structure complète de `secrets/`

Au-delà du flux `ms-s1-max` réellement branché ci-dessus, le repo expose la structure suivante (cf. `secrets/README.md` pour le tableau de statut détaillé) :

| Sous-chemin | Contenu | Statut actuel |
|---|---|---|
| `secrets/common.yaml` | secrets transverses (`infra.admin_email`, ...) | placeholder |
| `secrets/hosts/<host>.yaml` | secrets spécifiques host (mots de passe utilisateurs, clé hôte SSH, auth key Tailscale) | `ms-s1-max.yaml` réel ; `contabo.yaml` placeholder ; autres à créer à la demande |
| `secrets/stacks/<stack>.yaml` | secrets spécifiques stack (`token`, `*_password`, ...) | placeholders pour `immich`, `kopia`, `n8n`, `nextcloud`, `openwebui`, `pihole` |
| `secrets/cloud/<provider>.yaml` | identifiants cloud logiques (`subscription_id`, `account_id`, `project_id`) | placeholders pour `azure`, `cloudflare`, `gcp` |

Les clés YAML d'un fichier `secrets/stacks/<stack>.yaml` doivent correspondre **exactement** au champ `secrets` du contrat `stacks/<stack>/stack.nix` correspondant.

## Règles de chiffrement (`.sops.yaml`)

Les `creation_rules` sont déclarées **par chemin** (`secrets/common`, `secrets/hosts/.*`, `secrets/stacks/.*`, `secrets/cloud/.*`). Toutes les paths chiffrent vers la même Age recipient `admin_mfo` aujourd'hui ; la séparation par chemin permet une rotation per-stack ou per-provider plus tard sans réécrire les autres fichiers.

## Placeholders vs vrais secrets

Un fichier placeholder contient une chaîne `ENC[AES256_GCM,data:REPLACE_ME,...]` reconnaissable. Il n'est **pas** déchiffrable par SOPS : il existe uniquement pour figer la structure et la convention de nommage. Tout placeholder doit être matérialisé avec `sops` avant qu'un host ou une stack n'en consomme la valeur.
