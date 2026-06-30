{ config, lib, pkgs, ... }:

{
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    settings = {
      dns.upstreams = [ "10.0.0.1" ];
      dns.interface = "enp2s0";
      dns.listeningMode = "BIND";
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

  my.http.pihole.port = 8001;
}
