{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/".options = [ "noatime" ];
  fileSystems."/home".options = [ "noatime" ];
  fileSystems."/var".options = [ "noatime" ];
  fileSystems."/srv".options = [ "noatime" ];
  fileSystems."/nix".options = [ "noatime" ];
  fileSystems."/boot".options = [ "noatime" ];

  networking = {
    hostName = "rebellion";
    
    interfaces.enp2s0 = {
      ipv4.addresses = [{
        address = "10.0.0.10";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "fd00::1010:1010:1010:1010";
        prefixLength = 64;
      }];
    };
    defaultGateway = {
      address = "10.0.0.1";
      interface = "enp2s0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp2s0";
    };
    nameservers = ["10.0.0.1"];

    firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };

  # Select internationalisation properties.
  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  users.users.michael = {
    isNormalUser = true;
    extraGroups = ["wheel"];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRlrKF8fWgH82yPLq8+/yEyf6SJ+/OyFhVL7mD83MuN stuff@nero"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  environment.systemPackages = [
    pkgs.net-tools
    pkgs.bind
    pkgs.openssl
    pkgs.usbutils
  ];
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  programs.htop.enable = true;
  programs.git.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/hass 0770 root root -"
    "d /var/lib/hermes 0770 10000 10000 -"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    settings = {
      dns.upstreams = [ "10.0.0.1" ];
      dns.hosts = [
        "10.0.0.10 pihole.pushrax.com"
        "10.0.0.10 hass.pushrax.com"
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
      extraOptions = [ "--shm-size=1g" ];
    };
  };

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
