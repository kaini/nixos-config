{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 10000 10000 -"
  ];

  services.redis.servers.honcho = {
    enable = true;
  };
  
  virtualisation.oci-containers = {
    containers.hermes = {
      image = "nousresearch/hermes-agent:latest";
      volumes = [
        "/var/lib/hermes:/opt/data"
        "/var/lib/obsidian-vault:/mnt/obsidian-vault"
      ];
      environment = {
        HERMES_DASHBOARD = "1";
      };
      environmentFiles = [
        # File contents:
        # API_SERVER_KEY=xxx
        # HERMES_DASHBOARD_BASIC_AUTH_USERNAME=xxx
        # HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=xxx
        # HERMES_DASHBOARD_BASIC_AUTH_SECRET=xxx
        "/home/michael/hermes.secrets"
      ];
      cmd = [ "gateway" "run" ];
      ports = [ "127.0.0.1:9119:9119" ];
      extraOptions = [ "--shm-size=1g" ];
    };
  };

  my.http.hermes.port = 9119;
}