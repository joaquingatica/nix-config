{
  nixpkgs,
  nixpkgs-unstable,
  rust-overlay,
  ...
}: [
  {
    nixpkgs.config.allowUnfree = true; # for terraform
    nixpkgs.overlays = [
      (prev: final: {
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      })
      rust-overlay.overlays.default
    ];
  }
]
