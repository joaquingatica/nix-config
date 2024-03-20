{
  config,
  pkgs,
  ...
}: let
  zshInitExtra = ''
    # enable VI mode
    source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

    # AWS CLI helper functions
    source ${pkgs.awscli2}/share/zsh/site-functions/_aws

    # AWS credentials

    aws_use_mfa_profile() {
      local AWS_CLI_PROFILE=$1
      local ARN_OF_MFA=$2
      local AWS_MFA_PROFILE="$\{AWS_CLI_PROFILE}_mfa"
      local MFA_TOKEN_CODE=$3
      local DURATION=129600

      echo ""
      echo "AWS-CLI Profile: $AWS_CLI_PROFILE"
      echo "MFA ARN: $ARN_OF_MFA"
      echo ""
      read "MFA_TOKEN_CODE?Enter MFA Token Code: "
      read AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< $(
        aws --profile $AWS_CLI_PROFILE sts get-session-token \
          --duration $DURATION  \
          --serial-number $ARN_OF_MFA \
          --token-code $MFA_TOKEN_CODE \
          --output text | awk '{ print $2, $4, $5 }'
      )

      echo ""
      echo "- AWS_PROFILE: $AWS_MFA_PROFILE"
      echo "- AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
      echo "- AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
      echo "- AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"

      if [ -n "$AWS_ACCESS_KEY_ID" ]
      then
        `aws --profile $AWS_MFA_PROFILE configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"`
        `aws --profile $AWS_MFA_PROFILE configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"`
        `aws --profile $AWS_MFA_PROFILE configure set aws_session_token "$AWS_SESSION_TOKEN"`
        export AWS_SESSION_TOKEN
        export AWS_PROFILE=$AWS_MFA_PROFILE
      fi
    }

    aws_use_mfa_profile_anagram() {
      aws_use_mfa_profile anagram arn:aws:iam::172936817571:mfa/joaquin
    }

    aws_use_mfa_profile_blockfarming() {
      aws_use_mfa_profile blockfarming arn:aws:iam::666714533647:mfa/jgatica
    }

    aws_sso_dfh() {
      aws sso login --sso-session dfhsso
    }
  '';

  zshProfileExtra = ''
    # TODO: add zsh profile
    # AWS SAM Telemetry
    SAM_CLI_TELEMETRY=0
  '';
in {
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = builtins.replaceStrings ["${config.home.homeDirectory}"] [""] "${config.xdg.configHome}/zsh";
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
        save = 100000;
        size = 100000;
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "aws"
          "docker"
          "docker-compose"
          "git"
          "terraform"
        ];
        theme = "clean";
      };
      syntaxHighlighting.enable = true;
      initExtra = zshInitExtra;
      profileExtra = zshProfileExtra;
    };
  };
}
