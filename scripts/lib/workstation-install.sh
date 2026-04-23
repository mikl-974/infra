#!/usr/bin/env bash

resolve_repo_root() {
  local script_dir="$1"
  if [[ "$script_dir" == /nix/store/* ]]; then
    printf '%s\n' "$PWD"
  else
    cd "$script_dir/.." && pwd
  fi
}

list_hosts() {
  local hosts_dir="$1/targets"
  if [[ ! -d "$hosts_dir" ]]; then
    return 0
  fi

  local first=1
  local host
  while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    if [[ $first -eq 1 ]]; then
      printf '%s' "$host"
      first=0
    else
      printf ' %s' "$host"
    fi
  done < <(find "$hosts_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
  printf '\n'
}

read_nix_string_var() {
  local file="$1"
  local key="$2"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  sed -nE "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]+)\";.*$/\\1/p" "$file" | head -1
}

host_vars_file() {
  printf '%s/targets/%s/vars.nix\n' "$1" "$2"
}

host_default_file() {
  printf '%s/targets/%s/default.nix\n' "$1" "$2"
}

host_disko_file() {
  printf '%s/targets/%s/disko.nix\n' "$1" "$2"
}

host_exists() {
  local repo_root="$1"
  local host="$2"
  [[ -d "$repo_root/targets/$host" ]]
}

host_has_profile() {
  local repo_root="$1"
  local host="$2"
  local profile="$3"
  local default_file
  default_file="$(host_default_file "$repo_root" "$host")"

  [[ -f "$default_file" ]] && grep -q "../../modules/profiles/${profile}\.nix" "$default_file"
}

host_uses_disko() {
  local repo_root="$1"
  local host="$2"
  [[ -f "$(host_disko_file "$repo_root" "$host")" ]]
}

host_exposed_in_flake() {
  local repo_root="$1"
  local host="$2"
  grep -qE "^[[:space:]]*${host}[[:space:]]*=[[:space:]]*mkHost" "$repo_root/flake.nix"
}

flake_exposes_app() {
  local repo_root="$1"
  local app_name="$2"
  grep -qE "^[[:space:]]*${app_name}[[:space:]]*=[[:space:]]*mkApp" "$repo_root/flake.nix"
}

collect_active_dotfiles() {
  local home_file="$1"

  if [[ ! -f "$home_file" ]]; then
    return 0
  fi

  sed -nE 's/^[[:space:]]*".*"[.]source[[:space:]]*=[[:space:]]*\.\.\/dotfiles\/([^;[:space:]]+);[[:space:]]*$/\1/p' "$home_file"
}

collect_home_file_mappings() {
  local home_file="$1"

  if [[ ! -f "$home_file" ]]; then
    return 0
  fi

  sed -nE 's/^[[:space:]]*"([^"]+)"[.]source[[:space:]]*=[[:space:]]*\.\.\/dotfiles\/([^;[:space:]]+);[[:space:]]*$/\1|\2/p' "$home_file"
}

is_placeholder_value() {
  local value="${1:-}"
  [[ "$value" =~ ^DEFINE_ ]] || [[ "$value" == "/dev/DEFINE_DISK" ]] || [[ "$value" == "CHANGEME" ]]
}

is_supported_nixos_system() {
  local value="${1:-}"
  [[ "$value" == "x86_64-linux" || "$value" == "aarch64-linux" ]]
}
