{config, ...}: {
  programs = {
    claude-code = {
      enable = true;
      settings = {
        alwaysThinkingEnabled = false;
        attribution.commit = "   Co-Authored-By: Claude <noreply@anthropic.com>";
        enabledPlugins = {
          "frontend-design@claude-plugins-official" = true;
          "gitkraken-hooks@gitkraken" = true;
          "mattpocock-skills@claude-plugins-official" = true;
        };
        extraKnownMarketplaces = {
          gitkraken = {
            source = {
              path = "${config.home.homeDirectory}/.claude/plugins/marketplaces/gitkraken";
              source = "directory";
            };
          };
        };
        model = "opus";
        preferredNotifChannel = "ghostty";
        statusLine = {
          type = "command";
          command = "bash ${./statusline-command.sh}";
        };
        theme = "light";
      };
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
  };
}
