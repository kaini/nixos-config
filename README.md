# This is my NixOS config

This readme file contains some notes for me.

## Add or edit a secret

```sh
nix-shell -p sops --run "sops secrets/example.yaml"
```

## Development machine setup

Install nix (the package manager).

```sh
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```
