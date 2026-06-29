{ config, lib, pkgs, ... }:

let
  obsidian-headless = pkgs.callPackage ./obsidian-headless {};
in {
  environment.systemPackages = [
    obsidian-headless
  ];
}
