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
