{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
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

    darwinModules = {
      home-manager = import ./modules/home-manager.nix inputs;
      nix-homebrew = import ./modules/nix-homebrew.nix inputs;
      packages = import ./modules/packages.nix inputs;
      sops-nix = import ./modules/sops-nix.nix inputs;
      "hosts/ang-joaquin-mbp14" = [
        ./hosts/ang-joaquin-mbp14.nix
      ];
    };

    homeModules = {
      "joaquin/ang-joaquin-mbp14" = import ./home/joaquin/ang-joaquin-mbp14.nix;
    };

    darwinConfigurations = {
      "ang-joaquin-mbp14" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit inputs;};
        modules =
          self.darwinModules."hosts/ang-joaquin-mbp14"
          ++ self.darwinModules.home-manager
          ++ self.darwinModules.nix-homebrew
          ++ self.darwinModules.packages
          ++ self.darwinModules.sops-nix
          ++ [
            {
              home-manager.users.joaquin.imports = [
                self.homeModules."joaquin/ang-joaquin-mbp14"
              ];
            }
          ];
      };
    };

    devShell = eachSystem (pkgs:
      nixpkgs.legacyPackages.${pkgs.system}.mkShell {
        inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
      });
  };
}
