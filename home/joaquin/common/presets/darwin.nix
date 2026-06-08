{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../global
  ];

  home.homeDirectory = "/Users/${config.home.username}";
}
