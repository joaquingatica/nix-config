{pkgs, ...}: {
  # Decrypt at eval time - useful for NIX_NPM_TOKENS
  # ref: https://elvishjerricco.github.io/2018/06/24/secure-declarative-key-management.html
  # NOTE: quotes inside the a JSON string such as `NIX_NPM_TOKENS` must be escaped with triple backslashes `\\\`
  # TODO: uncomment when `builtins.extraBuiltins` is available
  # nix.envVars = builtins.fromJSON (builtins.extraBuiltins.decrypt "hosts/common/global/secrets/nix-env-vars.json");
}
