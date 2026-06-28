{ pkgs ? import <nixpkgs> {} }:

pkgs.buildNpmPackage {
  pname = "obsidian-headless";
  version = "0.0.12";

  src = pkgs.fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    rev = "14dafca";
    hash = "sha256-5GXO9FVATs8qlO6aQpOOtPYgPAb30lDxjM4VlfEAPCk=";
  };

  npmDepsHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  meta = with pkgs.lib; {
    description = "Headless client for Obsidian Sync.";
    license = licenses.obsidian;
  };
}
