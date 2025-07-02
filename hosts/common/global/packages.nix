{pkgs, ...}: let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = ["rust-src"];
  };
in {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    unstable.claude-code
    rustToolchain
    sops
    ssh-to-age
  ];
}
