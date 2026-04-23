# Placement des briques : foundation / homelab / workstation

## Objectif

Cette note fixe le placement architectural des briques demandees dans les trois repos :

- `foundation` = socle partage
- `homelab` = hosts serveur / infra / administration de hosts Linux
- `workstation` = poste utilisateur / desktop / dev local

## Tableau de decision

| Brique | Repo retenu | Justification | Statut dans cette passe |
|---|---|---|---|
| Cockpit | `homelab` | UI web d'administration d'un host Linux serveur / infra. Ce n'est ni une primitive partagee de socle, ni une app de poste utilisateur. | Documente ici, non implemente dans ce repo |
| Plugins Cockpit / VMs | `homelab` | Extensions UI d'administration de hosts, dependantes d'un backend serveur (`libvirt`, `qemu`, etc.). | Documente ici, non implemente dans ce repo |
| GitKraken | `workstation` | Application desktop de developpeur, liee au poste utilisateur. | Implemente |
| NordVPN | `workstation` | Client VPN utilisateur, comparable a WARP par nature: poste local, pas brique infra partagee. | Placement decide, integration laissee volontairement a une etape suivante |
| Podman | `workstation` | Ici il est traite comme moteur de containers local de developpement, couple au profil dev et a une UX Docker-compatible locale. | Implemente |
| Chromium | `workstation` | Application desktop quotidienne supplementaire, cote utilisateur. | Implemente |
| LocalSend | `workstation` | Application locale de partage de fichiers entre appareils utilisateur. | Implemente |
| Neovim | `workstation` | Editeur utilisateur / dev sur le poste, pas une primitive serveur partagee. | Implemente |

## Pourquoi Cockpit n'est pas dans `foundation`

`foundation` ne doit contenir que des briques vraiment generiques et reutilisables sans hypothese forte sur le repo consommateur.

Cockpit n'est pas une primitive de base :

- c'est une UI web d'administration d'host
- il depend du role de la machine administree
- ses plugins n'ont de sens que si les backends serveur existent deja

Conclusion :

- pas `foundation`
- pas `workstation`
- oui `homelab`

## Pourquoi Podman reste ici

Podman pourrait exister dans un socle partage si un besoin multi-repo stable emerge.

Dans cette passe, le besoin exprime est explicitement oriente poste de travail :

- profil `dev`
- compatibilite CLI Docker pour le shell `.NET`
- usage local de containers sur machine utilisateur

La bonne decision ici est donc :

- implementation locale dans `workstation`
- structure explicite via `modules/containers/podman.nix`
- activation via `modules/profiles/dev.nix`

## NordVPN : decision et limite volontaire

NordVPN releve bien de `workstation`, mais **n'est pas integre dans cette passe**.

Raison : sur la base disponible ici, `nixpkgs` 24.11 n'expose pas de module NixOS officiel ni de package officiel stable pour NordVPN.

Je ne rajoute donc pas :

- de packaging maison opaque
- de flake externe implicite
- de contournement non documente

La decision est explicite :

- placement retenu = `workstation`
- implementation reportee a une etape suivante avec une source packaging assumee

## Conventions retenues pour `workstation`

- application desktop quotidienne -> `modules/apps/daily.nix`
- application desktop dev -> `modules/apps/dev.nix`
- editeur / IDE -> `modules/apps/editors.nix`
- moteur de containers local -> `modules/containers/podman.nix`
- profil d'assemblage dev -> `modules/profiles/dev.nix`

## Frontiere stricte

- `foundation` : modules generiques, pas de choix produits lies a un seul usage
- `homelab` : administration serveur, Cockpit, virtualisation serveur, plugins Cockpit correspondants
- `workstation` : applications desktop, outils dev utilisateur, containers locaux de dev, VPN utilisateur
