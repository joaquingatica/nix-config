inputs @ {
  home-manager,
  mac-app-util,
  sops-nix,
  ...
}: [
  mac-app-util.darwinModules.default
  home-manager.darwinModules.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.joaquin = import ../home/joaquin/ang-joaquin-mbp14.nix;
      extraSpecialArgs = {inherit inputs;};
      sharedModules = [
        mac-app-util.homeManagerModules.default
        sops-nix.homeManagerModules.sops
      ];
    };
    # https://github.com/nix-darwin/nix-darwin/issues/682
    users.users.joaquin.home = "/Users/joaquin";
  }
]
