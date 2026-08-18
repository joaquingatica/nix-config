{config, ...}: {
  imports = [
    ../global
  ];

  home.homeDirectory = "/Users/${config.home.username}";
}
