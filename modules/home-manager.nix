inputs @ {home-manager, ...}: [
  home-manager.darwinModules.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs;};
    };
  }
]
