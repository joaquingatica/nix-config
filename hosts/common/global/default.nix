{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./nix.nix
    ./packages.nix
    ./shells.nix
    ./sops.nix
  ];
}
