{pkgs, ...}: {
  programs = {
    claude-code = {
      enable = true;
      package = pkgs.unstable.claude-code;
    };
    zsh.shellAliases.c = "claude";
  };

  home.file.".claude/statusline-command.sh".source = ./statusline-command.sh;
}
