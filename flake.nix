{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs = {
        flake-utils.follows = "flake-utils";
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
      };
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    home-manager,
    homebrew-bundle,
    homebrew-cask,
    homebrew-core,
    mac-app-util,
    nix-darwin,
    nix-homebrew,
    pre-commit-hooks,
    rust-overlay,
    sops-nix,
  }: let
    supportedSystems = ["x86_64-darwin" "aarch64-darwin"];
    eachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
  in {
    # for `nix flake check`
    checks = eachSystem (pkgs: {
      pre-commit-check = pre-commit-hooks.lib.${pkgs.system}.run {
        src = ./.;
        hooks = import ./pre-commit-hooks.nix;
      };
    });

    darwinConfigurations = {
      "ang-joaquin-mbp14" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules =
          [
            ./hosts/ang-joaquin-mbp14.nix
          ]
          ++ (import ./modules/home-manager.nix inputs)
          ++ (import ./modules/nix-homebrew.nix inputs)
          ++ (import ./modules/packages.nix inputs);
      };
    };

    devShell = eachSystem (pkgs:
      nixpkgs.legacyPackages.${pkgs.system}.mkShell {
        inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
      });
  };
}
