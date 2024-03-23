{pkgs, ...}: {
  environment.variables = {
    EDITOR = "vim";
  };

  # Decrypt at eval time - useful for NIX_NPM_TOKENS
  # ref: https://elvishjerricco.github.io/2018/06/24/secure-declarative-key-management.html
  nix.envVars = builtins.fromJSON (builtins.extraBuiltins.decrypt "hosts/common/global/secrets/nix-env-vars.json");
}
