{ config, lib, pkgs, ... }:

let
  cfg = config.my.http;
in {
  options.my.http = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ port, ... }: {
      options = {
        port = lib.mkOption {
          type = lib.types.port;
        };
      };
    }));
    default = {};
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults.email = "stuff@pushrax.com";

      certs."homelab.pushrax.com" = {
        domain = "*.pushrax.com";
        dnsProvider = "gandiv5";
        # File contents:
        # GANDIV5_PERSONAL_ACCESS_TOKEN=xxxxxxxx
        environmentFile = "/home/michael/acme.secrets";
        reloadServices = [ "haproxy" ];
        group = "haproxy";
      };
    };

    services.haproxy = {
      enable = true;
      config = builtins.readFile ./haproxy.cfg;
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };
}
