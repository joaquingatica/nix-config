{pkgs, ...}: {
  programs = {
    codex = {
      enable = true;
      # nixpkgs' cargo setup hook now makes these -sys crates link system libraries, but codex's
      # package doesn't provide them yet. Drop the override once nixpkgs' codex builds on darwin.
      package = pkgs.unstable.codex.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ (with pkgs.unstable; [aws-lc oniguruma sqlite zstd]);
      });
    };
    zsh.shellAliases.cx = "codex";
  };
}
