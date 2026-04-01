{
  description = "Nix flake for GitHub Copilot CLI - AI-powered coding assistant in your terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        github-copilot-cli = final.callPackage ./package.nix { };
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
          default = pkgs.github-copilot-cli;
          github-copilot-cli = pkgs.github-copilot-cli;
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.github-copilot-cli}/bin/copilot";
          };
          github-copilot-cli = {
            type = "app";
            program = "${pkgs.github-copilot-cli}/bin/copilot";
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
