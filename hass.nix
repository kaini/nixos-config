{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/hass 0770 root root -"
  ];

  virtualisation.oci-containers = {
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
      image = "ghcr.io/home-assistant/home-assistant:2026.7.0@sha256:cb76c9922b530f6a5063a15463eb3ad6de287d297c826713abda16795bb98980";
      privileged = true;
      extraOptions = [ "--network=host" ];
    };
  };

  my.http.hass.port = 8123;

  networking.firewall = {
    allowedTCPPorts = [ 80 443 18555 ];
    allowedUDPPorts = [ 1900 5353 ];
  };
}
