inputs @ {home-manager, ...}: [
  home-manager.darwinModules.home-manager
  {
    users.users.joaquin = {
      name = "joaquin";
      home = "/Users/joaquin";
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.joaquin = import ../home/joaquin/ang-joaquin-mbp14.nix;
      extraSpecialArgs = {inherit inputs;};
    };
  }
]
