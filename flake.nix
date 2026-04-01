{
  description = "Nix flake for GitHub Copilot CLI - AI-powered coding assistant in your terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        copilot = final.callPackage ./package.nix { };
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          default = pkgs.copilot;
          copilot = pkgs.copilot;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.copilot}/bin/copilot";
          };
          copilot = {
            type = "app";
            program = "${pkgs.copilot}/bin/copilot";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixpkgs-fmt
            nix-prefetch-git
            cachix
          ];
        };
      }) // {
        overlays.default = overlay;
      };
}
