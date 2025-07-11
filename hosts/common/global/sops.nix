{config, ...}: let
  userName = config.system.primaryUser;
  configDir = "${config.system.primaryUserHome}/.config";
in {
  sops = {
    age.keyFile = "${configDir}/sops/age/keys.txt";
    secrets = {
      "awscli/config" = {
        sopsFile = ./secrets/awscli.yaml;
        key = "config";
        path = "${configDir}/aws/config";
        owner = userName;
      };
      "gradle/gradle.properties" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configDir}/gradle/gradle.properties";
        owner = userName;
      };
      "npm/npmrc" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configDir}/npm/.npmrc";
        owner = userName;
      };
    };
  };
}
