{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.btrbk ];

  systemd.tmpfiles.rules = [
    "d /mnt/btr_pool/btrbk_snapshots 0750 btrbk btrbk -"
  ];

  services.btrbk.instances.btrbk = {
    onCalendar = "hourly";
    snapshotOnly = true;

    settings = {
      timestamp_format = "long";
      snapshot_preserve_min = "latest";
      snapshot_preserve = "24h 7d 4w 12m";

      volume."/mnt/btr_pool" = {
        snapshot_dir = "/mnt/btr_pool/btrbk_snapshots";

        subvolume = {
          root = { };
          home = { };
          var = { };
          srv = { };
        };
      };
    };
  };
}
