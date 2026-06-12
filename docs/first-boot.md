# First boot

## `ms-s1-max`

Verifier :

- session Hyprland disponible
- user `mfo` present
- `llama-cpp-qwen3-coder-next-q5` actif
- `cat /proc/cmdline` contient `iommu=pt amdgpu.gttsize=126976 ttm.pages_limit=32505856`
- `rocminfo` et `rocm-smi` disponibles
- `codex`, `hermes`, `llama-cli`, `hf`, `opencode-desktop`, `rider`, `webstorm`, `code` dans le PATH
- `btop`, `podman`, `podman-desktop` dans le PATH
- `/var/lib/llama-cpp/models` present et accessible
- `codex debug models | grep qwen3-coder-next` retourne le modele local

Commande utile :

```bash
nix run .#post-install-check -- --host ms-s1-max
```

## `contabo`

Verifier :

- SSH admin operationnel
- `tailscaled` actif
- `dokploy` operationnel

Commande utile :

```bash
nix run .#post-install-check -- --host contabo
```
