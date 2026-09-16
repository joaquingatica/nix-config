{
  nixpkgs,
  nixpkgs-unstable,
  rust-overlay,
  ...
}: [
  ({
    config,
    lib,
    ...
  }: {
    options.allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Names of unfree packages permitted by `allowUnfreePredicate`.";
    };

    config = {
      allowedUnfreePackages = [
        "terraform"
        "vscode"
      ];

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (nixpkgs.lib.getName pkg) config.allowedUnfreePackages;

      nixpkgs.overlays = [
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = prev.stdenv.hostPlatform.system;
          };
        })
        rust-overlay.overlays.default
      ];
    };
  })
]
