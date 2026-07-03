{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/obsidian-vault 0770 10000 10000 -"
    "d /var/lib/obsidian-config 0770 10000 10000 -"
  ];

  sops.secrets."obsidian.env" = {
    sopsFile = ./secrets/obsidian.env;
    format = "dotenv";
    restartUnits = [ "podman-obsidian-headless.service" ];
  };

  virtualisation.oci-containers = {
    containers.obsidian-headless = {
      image = "ghcr.io/belphemur/obsidian-headless-sync-docker:0.0.12@sha256:1ce5884a667a31215e6356eca81bf329eaf4c0c4a8cd50623b672c9fd410c5f2";
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
        config.sops.secrets."obsidian.env".path
      ];
    };
  };
}
