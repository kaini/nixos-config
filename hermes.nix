{ config, lib, pkgs, ... }:

let
  rohlik-mcp = pkgs.callPackage ./rohlik-mcp {};
in
lib.mkMerge [
  {
    # Rohlik MCP
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
  }

  {
    # Hindsight
    systemd.tmpfiles.rules = [
      "d /var/lib/hindsight-data 0770 801 801 -"
      "d /var/lib/hindsight-codex-auth 0770 801 801 -"
    ];

    users.groups.hindsight = {
      gid = 801;
    };

    users.users.hindsight = {
      isSystemUser = true;
      uid = 801;
      group = "hindsight";
    };

    sops.secrets."hindsight.env" = {
      sopsFile = ./secrets/hindsight.env;
      format = "dotenv";
      restartUnits = [ "podman-hindsight.service" ];
    };

    virtualisation.oci-containers.containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:0.9.1@sha256:a0e937366261b8a8f20ebcaf13758c689c381dcbbf01684e4375c2787c8c666d";
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
      extraOptions = [
        "--uidmap=0:0:1"
        "--uidmap=1000:801:1"
        "--gidmap=0:0:1"
        "--gidmap=1000:801:1"
      ];
    };

    my.http.hindsight.port = 9999;
  }

  {
    # Hermes
    systemd.tmpfiles.rules = [
      "d /var/lib/hermes 0770 ${toString config.users.users.hermes.uid} ${toString config.users.groups.hermes.gid} -"
    ];

    users.groups.hermes = {
      gid = 800;
    };

    users.users.hermes = {
      isSystemUser = true;
      uid = 800;
      group = "hermes";
    };

    sops.secrets."hermes.env" = {
      sopsFile = ./secrets/hermes.env;
      format = "dotenv";
      restartUnits = [ "podman-hermes.service" ];
    };

    fileSystems."/mnt/hermes-obsidian-vault" = {
      device = "/var/lib/obsidian-vault";
      fsType = "none";
      options = [
        "bind"
        "X-mount.idmap=u:${toString config.users.users.obsidian.uid}:${toString config.users.users.hermes.uid}:1 g:${toString config.users.groups.obsidian.gid}:${toString config.users.groups.hermes.gid}:1"
      ];
    };

    virtualisation.oci-containers.containers.hermes = {
      image = "nousresearch/hermes-agent:v2026.8.19@sha256:3811ed13da874fba2ac99b6d492db9a203d34cb6dccf90d886948c00d0ccec09";
      volumes = [
        "/var/lib/hermes:/opt/data"
        "/mnt/hermes-obsidian-vault:/mnt/obsidian-vault"
      ];
      environment = {
        HERMES_DASHBOARD = "1";
      };
      environmentFiles = [ config.sops.secrets."hermes.env".path ];
      cmd = [ "gateway" "run" ];
      ports = [ "127.0.0.1:9119:9119" ];
      extraOptions = [
        "--shm-size=1g"
        "--uidmap=0:0:1"
        "--uidmap=10000:${toString config.users.users.hermes.uid}:1"
        "--gidmap=0:0:1"
        "--gidmap=10000:${toString config.users.groups.hermes.gid}:1"
      ];
    };

    my.http.hermes.port = 9119;
  }
]
