{...}: {
  programs = {
    difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };
    gh = {
      enable = true;
    };
    gpg = {
      enable = true;
      # GitHub signs merges made in its web UI with this key; validate it by hand with a local
      # signature, since `trust = "ultimate"` would also let it certify other keys
      publicKeys = [{source = ./github-web-flow.gpg;}];
    };
    git = {
      enable = true;
      signing = {
        key = null; # let GnuPG decide what signing key to use depending on commit’s author
        signByDefault = true;
      };
      settings = {
        color.ui = true;
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
