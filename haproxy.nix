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
      config = ''
        global
            log /dev/log local0
            log /dev/log local1 notice

            h2-workaround-bogus-websocket-clients

        defaults
            mode http
            log global

            timeout connect 5s
            timeout client 30s
            timeout server 30s
            timeout tunnel 1h

        frontend http
            bind :80
            http-request redirect scheme https code 301

        frontend https
            bind :443 ssl crt /var/lib/acme/homelab.pushrax.com/full.pem alpn h2,http/1.1
            bind quic4@:443 ssl crt /var/lib/acme/homelab.pushrax.com/full.pem alpn h3

            http-response set-header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
            option forwarded
            option forwardfor

            filter compression
            compression algo gzip
            compression direction both

            ${lib.concatMapAttrsStringSep "\n    " (name: value: "use_backend ${name} if { req.hdr(host) -i ${name}.pushrax.com }") cfg}
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };
}
