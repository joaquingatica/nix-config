{
  config,
  lib,
  ...
}: {
  programs = {
    # Not through `difftastic.git.enable`: it always sets `diff.external`, so even piped `git diff`
    # output is difftastic's display, and patches saved by scripts and agents can't be applied.
    difftastic.enable = true;
    gh = {
      enable = true;
    };
    gpg = {
      enable = true;
      publicKeys = [
        # GitHub signs merges made in its web UI with this key; validate it by hand with a local
        # signature, since `trust = "ultimate"` would also let it certify other keys
        {source = ./github-web-flow.gpg;}
      ];
    };
    git = {
      enable = true;
      signing = {
        key = null; # let GnuPG decide what signing key to use depending on commit’s author
        signByDefault = true;
      };
      settings = {
        alias.dft = "difftool";
        color.ui = true;
        diff.tool = "difftastic";
        difftool = {
          prompt = false;
          difftastic.cmd = "${lib.getExe config.programs.difftastic.package} $LOCAL $REMOTE";
        };
        init.defaultBranch = "main";
        # Include common parent when merge conflicts arise
        merge.conflictStyle = "diff3";
        pull.ff = "only";
      };
    };
    lazygit = {
      enable = true;
    };
  };
}
