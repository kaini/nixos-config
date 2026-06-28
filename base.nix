{ config, lib, pkgs, ... }:

{
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

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.net-tools
    pkgs.bind
    pkgs.openssl
    pkgs.usbutils
    pkgs.file
  ];
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  programs.htop.enable = true;
  programs.git.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
