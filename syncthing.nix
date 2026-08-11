{ config, ... }:

{
  sops.secrets."syncthing-gui-password" = {
    sopsFile = ./secrets/syncthing.yaml;
    format = "yaml";
    key = "SYNCTHING_GUI_PASSWORD";
  };

  sops.templates."syncthing-gui-password" = {
    content = config.sops.placeholder."syncthing-gui-password";
    owner = "syncthing";
    restartUnits = [ "syncthing-init.service" ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    # The GUI is only reachable through the local reverse proxy.
    guiAddress = "127.0.0.1:8384";
    guiPasswordFile = config.sops.templates."syncthing-gui-password".path;
    settings.gui = {
      user = "syncthing";
      # HAProxy preserves the public Host header, which Syncthing would
      # otherwise reject because its GUI listens on localhost.
      insecureSkipHostcheck = true;
    };
  };

  my.http.syncthing.port = 8384;
}
