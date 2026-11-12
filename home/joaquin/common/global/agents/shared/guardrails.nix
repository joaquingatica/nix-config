{pkgs, ...}: let
  blockTerraform = pkgs.writeShellApplication {
    name = "block-terraform";
    runtimeInputs = [pkgs.jq pkgs.gnugrep];
    text = builtins.readFile ./block-terraform.sh;
  };
in {
  # Each agent runs it through the profile path, /etc/profiles/per-user/joaquin/bin/block-terraform:
  # Claude Code and Codex as a PreToolUse hook in their config files, and opencode from a plugin.
  home.packages = [blockTerraform];
}
