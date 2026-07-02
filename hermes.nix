{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0770 10000 10000 -"
    "d /var/lib/hindsight-data 0770 1000 1000 -"
    "d /var/lib/hindsight-codex-auth 0770 1000 1000 -"
  ];
  
  services.searx = {
    enable = true;
    # File contents:
    # SEARX_SECRET_KEY=
    environmentFile = "/home/michael/searx.secrets";
    settings = {
      server.port = 8844;
      server.bind_address = "10.88.0.1";
      server.secret_key = "$SEARX_SECRET_KEY";
      search.formats = [ "json" "html" ];
    };
  };

  virtualisation.oci-containers = {
    containers.hindsight = {
      image = "ghcr.io/vectorize-io/hindsight:0.8.3@sha256:274704505b2720ac9a5c816c559044c1e8c6b51d47017317ae049ed2952f5ab1";
      environment = {
        HOME = "/home/hindsight";
        HINDSIGHT_API_WORKER_ID = "hindsight";
        HINDSIGHT_API_LLM_PROVIDER = "openai-codex";
        HINDSIGHT_API_TENANT_EXTENSION = "hindsight_api.extensions.builtin.tenant:ApiKeyTenantExtension";
      };
      environmentFiles = [
        # File contents:
        # HINDSIGHT_API_TENANT_API_KEY=
        # HINDSIGHT_CP_DATAPLANE_API_KEY=
        # HINDSIGHT_CP_ACCESS_KEY=
        "/home/michael/hindsight.secrets"
      ];
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
  my.http.hindsight.port = 9999;

  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 8844 ];
}