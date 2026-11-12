{
  config,
  lib,
  ...
}: {
  options.nixConfigPath = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.config/nix-config";
    description = "Where this repository is checked out, for files linked out of the store.";
  };
}
