{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../global
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    unstable.colima
  ];

  homebrew = {
    enable = true;
    brews = [
      "difftastic"
      "grpcui"
    ];
    casks = [
      "colima-ui"
    ];
    taps = [
      "RyanCopley/homebrew-tap"
    ];
    onActivation = {
      autoUpdate = true;
      # remove packages not listed above
      cleanup = "uninstall";
    };
  };

  nix = {
    distributedBuilds = false;

    linux-builder = {
      enable = false;
      maxJobs = 4;
      config = {
        virtualisation.cores = 4;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # see options: https://github.com/LnL7/nix-darwin/tree/bcc8afd06e237df060c85bad6af7128e05fd61a3/modules/system/defaults
    defaults = {
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 3.0;
      };
      ActivityMonitor = {
        SortColumn = "CPUUsage";
        SortDirection = 0; # descending
      };
      dock = {
        autohide = true;
        largesize = 52;
        magnification = true;
        # persistent-apps = [
        #   add apps pinned to the dock
        #   "/Applications/Firefox.app"
        # ];
        show-recents = false;
        tilesize = 50;
        wvous-bl-corner = 2; # Mission Control
        wvous-br-corner = 3; # Application Windows
        wvous-tl-corner = 1; # Disabled
        wvous-tr-corner = 12; # Notification Center
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv"; # Column View
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      magicmouse = {
        MouseButtonMode = "TwoButton";
      };
      menuExtraClock = {
        IsAnalog = false;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 0;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = false;
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleTemperatureUnit = "Celsius";
        AppleWindowTabbingMode = "always";
        "com.apple.trackpad.scaling" = 3.0;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };
    };

    primaryUser = "joaquin";

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
  };
}
