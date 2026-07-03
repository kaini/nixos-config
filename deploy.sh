#!/bin/bash
set -xeuo pipefail
cd "$(dirname "$0")"

HOST="$1"

rsync -a --delete --exclude=.git --chmod=Du=rwx,Dgo=,Fu=rw,Fgo= . "$HOST:~/nixos"
ssh "$HOST" "cd nixos && sudo nixos-rebuild switch"
