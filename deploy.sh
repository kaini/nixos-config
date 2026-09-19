#!/bin/bash
set -xeuo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" == "--dry-run" ]]; then
  ACTION="dry-build"
  shift
else
  ACTION="switch"
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [--dry-run] HOST" >&2
  exit 2
fi

HOST="$1"

rsync -a --no-links --delete --exclude=.git --chmod=Du=rwx,Dgo=,Fu=rw,Fgo= . "$HOST:~/nixos"
ssh "$HOST" "cd nixos && sudo nixos-rebuild $ACTION"
