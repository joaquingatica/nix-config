{exec, ...}: let
  # Decrypt a file using sops and return the result as a string
  decrypt = file:
    exec [
      "bash"
      "-c"
      ''
        set -euo pipefail
        f=$(mktemp)
        trap "rm $f" EXIT
        set -x
        sops -d "${file}" > $f
        nix-instantiate --eval --expr "builtins.readFile $f"
      ''
    ];

  # Decrypt a file using sops and return the resulting path as a string
  decryptFile = tmpPrefix: file:
    exec [
      "bash"
      "-c"
      ''
        set -euo pipefail
        f="$(mktemp -p "$(getconf DARWIN_USER_TEMP_DIR)" ${tmpPrefix}.XXXXXXXXXX)"
        set -x
        sops -d "${file}" > $f
        echo $f
      ''
    ];

  # Decrypt a file using sops and return the resulting path as a string
  decryptFilePath = tmpPrefix: file:
    builtins.toPath (decryptFile tmpPrefix file);
in {
  inherit decrypt decryptFilePath;
}
