{
  config,
  lib,
  pkgs,
  ...
}: let
  gulp-cli = pkgs.callPackage ./npm-packages/gulp-cli {};
in {
  imports = [
    ./git.nix
    ./shells.nix
  ];

  home = {
    file = {
      "${config.xdg.configHome}/ghostty/config" = {
        source = ./ghostty-config.ini;
      };
    };

    packages = with pkgs; [
      awscli2
      docker
      docker-compose
      gnupg
      gulp-cli
      kubectl
      kubernetes-helm
      nodejs_22
      openjdk21
      opentofu
      pre-commit
      protobuf
      python3
      terraform
      yq
    ];

    sessionVariables = {
      AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
      EDITOR = "code -w";
      GRADLE_USER_HOME = "${config.xdg.configHome}/gradle";
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/.npmrc";
      # AWS SAM Telemetry
      SAM_CLI_TELEMETRY = 0;
      SHORTCUT_CONFIG_FILE = (import ./shortcut.nix {inherit config pkgs;}).configFilePath;
    };

    sessionPath = [
      "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
      # workaround for missing username in PATH for some GUI apps such
      # as GitKraken, using invalid path "/etc/profiles/per-user//bin"
      "/etc/profiles/per-user/${config.home.username}/bin"
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = lib.mkDefault "25.05";

    username = lib.mkDefault "joaquin";
  };

  programs = {
    claude-code = {
      enable = true;
      settings = {
        alwaysThinkingEnabled = false;
        attribution.commit = "   Co-Authored-By: Claude <noreply@anthropic.com>";
        enabledPlugins = {
          "gitkraken-hooks@gitkraken" = true;
        };
        extraKnownMarketplaces = {
          gitkraken = {
            source = {
              path = "${config.home.homeDirectory}/.claude/plugins/marketplaces/gitkraken";
              source = "directory";
            };
          };
        };
        preferredNotifChannel = "ghostty";
        theme = "light";
      };
    };
    home-manager = {
      enable = true;
    };
    lazydocker = {
      enable = true;
    };
    opencode = {
      enable = true;
      settings = {
        model = "deepinfra/moonshotai/Kimi-K2.5";
        provider = {
          deepinfra = {
            name = "DeepInfra";
          };
        };
      };
    };
    ssh = {
      enable = true;
      includes = [
        "~/.colima/ssh_config"
      ];
    };
    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        # dracula-theme.theme-dracula
      ];
    };
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}
