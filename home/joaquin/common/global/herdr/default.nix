{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    (inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # herdr has no setting for any of these:
      # - private-notifications: name the session in notifications, not the project folder and
      #   tab, which leak project names while screen sharing.
      # - session-window-title: add a {session} placeholder to ui.window_title.
      # - notification-bell: ring the bell after each Ghostty notification, since macOS hides
      #   notifications from the frontmost app and Ghostty marks the ringing tab.
      patches =
        (old.patches or [])
        ++ [
          ./patches/private-notifications.patch
          ./patches/session-window-title.patch
          ./patches/notification-bell.patch
        ];
    }))
  ];

  programs.zsh.shellAliases.h = "herdr --session";
}
