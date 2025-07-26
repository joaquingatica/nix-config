{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./shells.nix
  ];

  home = {
    packages = with pkgs; [
      awscli2
      corepack
      docker
      docker-compose
      gnupg
      grpcurl
      kubectl
      kubernetes-helm
      nodejs
      nodePackages.gulp-cli
      nodePackages.vercel
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
    home-manager = {
      enable = true;
    };
    lazydocker = {
      enable = true;
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
