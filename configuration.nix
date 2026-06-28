{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./system.nix
    ./haproxy.nix
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/hass 0770 root root -"
    "d /var/lib/hermes 0770 10000 10000 -"
  ];

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

  services.postgresql = {
    enable = true;
    extensions = ps: with ps; [ pgvector ];
  };

  services.redis.servers.hancho = {
    enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      volumes = [
        "/var/lib/hass:/config"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = config.time.timeZone;
      capabilities = {
        NET_RAW = true;
        NET_ADMIN = true;
      };
      devices = [
        "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_5266936139b6ed118c46d60ea8669f5d-if00-port0:/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_5266936139b6ed118c46d60ea8669f5d-if00-port0"
      ];
      image = "ghcr.io/home-assistant/home-assistant:stable";
      privileged = true;
      extraOptions = [ "--network=host" ];
    };

    containers.hermes = {
      image = "nousresearch/hermes-agent:latest";
      volumes = [
        "/var/lib/hermes:/opt/data"
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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
