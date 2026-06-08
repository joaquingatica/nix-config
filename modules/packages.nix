{
  nixpkgs,
  nixpkgs-unstable,
  rust-overlay,
  ...
}: [
  {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (nixpkgs.lib.getName pkg) [
        "claude-code"
        "raycast"
        "terraform"
        "vscode"
      ];
    nixpkgs.overlays = [
      (prev: final: {
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
        };
      })
      rust-overlay.overlays.default
    ];
  }
]
