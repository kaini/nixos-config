{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 10000 10000 -"
    "d /var/lib/hindsight-data 0770 10001 10001 -"
  ];
  
  virtualisation.oci-containers = {
    containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:latest";
      user = "10001:10001";
      environment = {
        HOME = "/home/hindsight";
        HINDSIGHT_API_WORKER_ID = "hindsight";
        HINDSIGHT_API_LLM_PROVIDER = "openai-codex";
      };
      volumes = [
        "/var/lib/hindsight-data:/home/hindsight/.pg0"
      ];
      ports = [
        "127.0.0.1:8888:8888"
        "127.0.0.1:9999:9999"
      ];
    };

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