{pkgs, ...}: {
  nix = {
    enable = true;

    extraOptions = ''
      # keep-outputs = true
      # keep-derivations = true
    '';

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    settings = {
      # https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = pkgs.stdenv.isLinux;
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
      trusted-users = ["root" "joaquin"];
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
