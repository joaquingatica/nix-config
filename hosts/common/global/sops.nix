{config, ...}: let
  configHome = "${config.system.primaryUserHome}/.config";
in {
  sops = {
    age.keyFile = "${configHome}/sops/age/keys.txt";
    secrets = {
      "awscli/config" = {
        sopsFile = ./secrets/awscli.yaml;
        key = "config";
        path = "${configHome}/aws/config";
      };
      "gradle/gradle.properties" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configHome}/gradle/gradle.properties";
      };
      "npm/npmrc" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configHome}/npm/.npmrc";
      };
    };
  };
}
