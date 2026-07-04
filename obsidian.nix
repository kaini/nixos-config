{ config, lib, pkgs, ... }:

let
  obsidian-headless = pkgs.callPackage ./obsidian-headless/obsidian-headless.nix {};

  check-login-sh = pkgs.writeShellApplication {
    name = "check-obsidian-headless-login";
    runtimeInputs = [ obsidian-headless pkgs.coreutils pkgs.which ];
    text = ''
      LOGIN="$(ob login < /dev/null || true)"
      echo "$LOGIN"
      if [[ "$LOGIN" != "Logged in as"* ]]; then
        echo "Not logged in to Obsidian. Please run"
        echo "  sudo -u $(whoami) $(which ob) login"
        echo "to authenticate."
        exit 1
      fi
    '';
  };

  vault-dir = "/var/lib/obsidian-vault";
  vault-config = "/var/lib/obsidian-config";
in
{
  systemd.tmpfiles.rules = [
    "d ${vault-dir} 0770 10000 10000 -"
    "d ${vault-config} 0770 10000 10000 -"
  ];

  users.groups.obsidian = {
    gid = 10000;
  };

  users.users.obsidian = {
    isSystemUser = true;
    uid = 10000;
    group = "obsidian";
    home = vault-config;
  };

  systemd.services.obsidian-headless = {
    description = "obsidian-headless sync";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "obsidian";
      Group = "obsidian";
      Type = "simple";
      ExecStartPre = "${check-login-sh}/bin/check-obsidian-headless-login";
      ExecStart = "${obsidian-headless}/bin/ob sync --path ${vault-dir} --continuous";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
