{ config, lib, pkgs, ... }:

{ 
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
}
