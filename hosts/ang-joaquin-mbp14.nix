{...}: {
  imports = [
    ./common/users/joaquin.nix
  ];

  networking = {
    hostName = "ang-joaquin-mbp14";
    localHostName = "ang-joaquin-mbp14";
    computerName = "ang-joaquin-mbp14";
  };
}
