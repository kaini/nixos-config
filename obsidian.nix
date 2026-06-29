{ config, lib, pkgs, ... }:

let
  obsidian-headless = pkgs.callPackage ./packages/obsidian-headless {};
in {
  environment.systemPackages = [
    obsidian-headless
  ];
}
