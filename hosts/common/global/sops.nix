{config, ...}: let
  user = config.users.users.joaquin;
  configDir = "${user.home}/.config";
in {
  sops = {
    age.keyFile = "${configDir}/sops/age/keys.txt";
    secrets = {
      "awscli/config" = {
        sopsFile = ./secrets/awscli.yaml;
        key = "config";
        path = "${configDir}/aws/config";
        owner = user.name;
      };
      "gradle/gradle.properties" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configDir}/gradle/gradle.properties";
        owner = user.name;
      };
      "npm/npmrc" = {
        sopsFile = ./secrets/secrets.yaml;
        path = "${configDir}/npm/.npmrc";
        owner = user.name;
      };
    };
  };
}
