{pkgs, ...}: {
  programs = {
    opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
    };
    zsh.shellAliases.oc = "opencode";
  };

  # opencode has no command hooks, so this plugin runs the shared block-terraform guardrail.
  xdg.configFile."opencode/plugins/block-terraform.js".source = ./block-terraform-plugin.js;
}
