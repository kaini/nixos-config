{ config, lib, pkgs, ... }:

{
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    settings = {
      dns.upstreams = [ "10.0.0.1" ];
      dns.hosts = [
        "10.0.0.10 pihole.pushrax.com"
        "10.0.0.10 hass.pushrax.com"
        "10.0.0.10 hermes.pushrax.com"
      ];
    };
    lists = [
      {
        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
        type = "block";
        enabled = true;
        description = "hagezi blocklist";
      }
    ];
  };

  services.pihole-web = {
    enable = true;
    ports = [ 8001 ];
    hostName = "pihole.pushrax.com";
  };
}
