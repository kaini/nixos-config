{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/obsidian-vault 0770 10000 10000 -"
    "d /var/lib/obsidian-config 0770 10000 10000 -"
  ];
  
  virtualisation.oci-containers = {
    containers.obsidian-headless = {
      image = "ghcr.io/belphemur/obsidian-headless-sync-docker:0.0.12@sha256:c9c7928e796111077b7e6ca23483cd25b6df11ac8d7243ea17b3c6a6b09f7ef6";
      volumes = [
        "/var/lib/obsidian-vault:/vault"
        "/var/lib/obsidian-config:/home/obsidian/.config"
      ];
      environment = {
        PUID = "10000";
        PGID = "10000";
        EXCLUDED_FOLDERS = "";
      };
      environmentFiles = [
        # File contents:
        # OBSIDIAN_AUTH_TOKEN=xxx
        # VAULT_NAME=xxx
        # VAULT_PASSWORD=xxx
        "/home/michael/obsidian.secrets"
      ];
    };
  };
}
