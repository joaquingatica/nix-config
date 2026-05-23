{
  config,
  pkgs,
  ...
}: let
  shortcut = import ./shortcut.nix {inherit config pkgs;};
  zshInitContent = ''
    # AWS CLI helper functions
    source ${pkgs.awscli2}/share/zsh/site-functions/_aws

    # make sure `brew` and installed brews are available
    eval "$(brew shellenv)"

    # alias for shortcut package, needed to make sure the parent shell changes directory
    ${shortcut.zshInitContent}
  '';

  zshProfileExtra = ''
    # prevent duplicate entries in $PATH
    # $path array is tied to $PATH
    typeset -U path PATH
  '';
in {
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
    };
    bat.enable = true;
    btop.enable = true;
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    mcfly = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      fzf.enable = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        command_timeout = 10000; # 10 seconds
      };
    };
    zoxide.enable = true;
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      dotDir = "${config.xdg.configHome}/zsh";
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        expireDuplicatesFirst = true;
        extended = true;
        findNoDups = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        save = 1000000;
        size = 1000000;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "aws"
          "docker"
          "docker-compose"
          "git"
          "terraform"
        ];
        theme = "clean";
      };
      plugins = [
        {
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
      shellAliases =
        {
          # cat on steroids
          cat = "bat";
          cl = "claude";
          # open github repository for current directory
          ghrepo = "gh repo view -w";
          # open github PR for current branch in directory repository
          ghpr = "gh pr view -w";
          # search in history
          hg = "history | grep";
          # https://gist.github.com/dersam/0ec781e8fe552521945671870344147b
          kraken = "open -na \"GitKraken\" --args -p \"$(git rev-parse --show-toplevel)\"";
          lzd = "lazydocker";
          lg = "lazygit";
          oc = "opencode";
          sc = "suitecloud";
        }
        // shortcut.shellAliases;
      syntaxHighlighting.enable = true;
      initContent = zshInitContent;
      profileExtra = zshProfileExtra;
    };
  };
}
