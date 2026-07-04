{ config, lib, pkgs, ... }:

let
  rohlik-mcp = pkgs.callPackage ./rohlik-mcp {};
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 10000 10000 -"
    "d /var/lib/hindsight-data 0770 1000 1000 -"
    "d /var/lib/hindsight-codex-auth 0770 1000 1000 -"
  ];
  
  sops.secrets."hermes.env" = {
    sopsFile = ./secrets/hermes.env;
    format = "dotenv";
    restartUnits = [ "podman-hermes.service" ];
  };

  sops.secrets."hindsight.env" = {
    sopsFile = ./secrets/hindsight.env;
    format = "dotenv";
    restartUnits = [ "podman-hindsight.service" ];
  };

  sops.secrets."rohlik-mcp.env" = {
    sopsFile = ./secrets/rohlik-mcp.env;
    format = "dotenv";
    restartUnits = [ "rohlik-mcp.service" ];
  };

  users.groups.rhlmcp = {};

  users.users.rhlmcp = {
    isSystemUser = true;
    group = "rhlmcp";
  };

  systemd.services.rohlik-mcp = {
    description = "Rohlik MCP";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "rhlmcp";
      Group = "rhlmcp";
      Type = "simple";
      ExecStart = "${rohlik-mcp}/bin/rohlik-mcp";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "ROHLIK_BASE_URL=https://www.gurkerl.at"
        "ROHLIK_MCP_HOST=10.88.0.1"
        "ROHLIK_MCP_PORT=8787"
      ];
      EnvironmentFile = config.sops.secrets."rohlik-mcp.env".path;
    };
  };
  
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 8787 ];

  virtualisation.oci-containers = {
    containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:0.8.4@sha256:2c60f233eaba8f51db31adb920a560735aaf6f314e4b63c36c73159742dfa1a7";
      environment = {
        HOME = "/home/hindsight";
        HINDSIGHT_API_WORKER_ID = "hindsight";
        HINDSIGHT_API_LLM_PROVIDER = "openai-codex";
        HINDSIGHT_API_TENANT_EXTENSION = "hindsight_api.extensions.builtin.tenant:ApiKeyTenantExtension";
      };
      environmentFiles = [ config.sops.secrets."hindsight.env".path ];
      volumes = [
        "/var/lib/hindsight-data:/home/hindsight/.pg0"
        "/var/lib/hindsight-codex-auth:/home/hindsight/.codex"
      ];
      ports = [
        "127.0.0.1:8888:8888"
        "127.0.0.1:9999:9999"
      ];
    };

    containers.hermes = {
      image = "nousresearch/hermes-agent:v2026.7.1@sha256:b6c019227889e6675424a2b6223b2cafdd36bf7d1048d1ddd8e043b880d6cc0f";
      volumes = [
        "/var/lib/hermes:/opt/data"
        "/var/lib/obsidian-vault:/mnt/obsidian-vault"
      ];
      environment = {
        HERMES_DASHBOARD = "1";
      };
      environmentFiles = [ config.sops.secrets."hermes.env".path ];
      cmd = [ "gateway" "run" ];
      ports = [ "127.0.0.1:9119:9119" ];
      extraOptions = [ "--shm-size=1g" ];
    };
  };

  my.http.hermes.port = 9119;
  my.http.hindsight.port = 9999;
}
