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
      image = "ghcr.io/home-assistant/home-assistant:2026.11.3@sha256:24e541ddae5818bf8eb27898b9ba00d0c344a655aa5097e9e9bd4b19356be847";
      privileged = true;
      extraOptions = [ "--network=host" ];
    };
  };

  services.esphome = {
    enable = true;
    address = "127.0.0.1";
  };

  my.http.hass.port = 8123;
  my.http.esphome.port = config.services.esphome.port;

  networking.firewall = {
    allowedTCPPorts = [ 80 443 18555 ];
    allowedUDPPorts = [ 1900 5353 ];
  };
}
