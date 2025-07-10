# Joaquin's `nix-darwin` Configuration

## Setup Environment

### 0. Update configuration for new system

1. Create appropriate folder in `./hosts` with the base configuration
2. Update `darwinConfigurations` in `flake.nix` to use the new configuration

### 1. Setup `nix`

1. Run `curl -L https://nixos.org/nix/install | sh` to install Nix.
2. In a new terminal, verify installation with `nix --version`
3. Enable flake support:

```shell
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Documentation: https://nix.dev/install-nix

### 2. Pre installation

#### 2.1. Create `~/.gnupg` folder

If `~/.gnupg` folder doesn't exist, create it: `mkdir ~/.gnupg`.

This is to work around a minor `gnupg` agent issue that [prints warnings if folder doesn't exist](https://github.com/NixOS/nixpkgs/issues/29331#issuecomment-685282396).

### 2.2. Setup encryption keys

1. From the password manager, create the `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub` files.
2. Create the AGE keys file by running `ssh-to-age -i ~/.ssh/id_ed25519 -private-key > ~/.config/sops/age/keys.txt`

If at some point the SSH keys need to be recreated, run `ssh-keygen -t ed25519 -C "<email-here>"`.
Keep in mind to **not** set a passphrase for the key in order to be used from `home-manager`.

### 3. Setup repository & `nix-darwin`

1. Clone this repository in the folder: `~/.config`
2. In the cloned folder, run `sudo make install`
3. Run `direnv allow` to set up the project locally for development
4. Run `sudo make switch` to apply the configuration after the initial setup

### 4. Post installation

#### 4.1. Ensure `~/.gnupg` permissions

Run `gpg --list-secret-keys --keyid-format=long` and verify that no `unsafe permissions on homedir`
warning is printed. If a warning is printed, run the following commands to fix the permissions:

```shell
find ~/.gnupg -type f -exec chmod 600 {} \; # Set 600 for files
find ~/.gnupg -type d -exec chmod 700 {} \; # Set 700 for directories
```

#### 4.2. Restart GPG agent

Run `gpgconf --kill gpg-agent` to restart the GPG agent and apply the new configurations.

#### 4.3. Setup commit signing

Follow the steps in [this guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)
to set up commit signing and signature verification in Git and GitHub.

#### 4.4. Other caveats

##### IntelliJ & JetBrains IDEs

Update the following settings:

- `Build, Execution, Deployment`
  - `Build Tools > Gradle` -> in `Gradle user home` enter `/Users/joaquin/.config/gradle`
  - `Docker` -> select `Colima` option
  - `Docker > Tools` -> in `Docker executable` and `Docker Compose executable` enter the
    output of `which docker` (likely `/etc/profiles/per-user/joaquin/bin/docker`)

## Usage

- **Apply changes** from configuration: `sudo make switch`.
- **Format** the project's source code: `make fmt`.
- **Edit secrets**: `make sops-*` commands provided in [`Makefile`](./Makefile).

See [`Makefile`](./Makefile) for other commands.

## Directory Structure

The directory structure and documentation is inspired and based of off the [Effect-TS/infra](https://github.com/Effect-TS/infra/blob/cfcb7a25f066da20ca572b5ebf64d2faa7f6f74e/README.md)
repository.

### Nix Darwin

The directory structure of this project is optimized for sharing configuration as much as possible.

The `./hosts` directory contains all systems that are managed by Nix Darwin. Each host has its own
file/directory (with the same name as the machine's hostname).

In addition, the `./hosts` directory contains a `./common` subdirectory. This directory contains
configuration that can be shared across all hosts. Within the `./common` subdirectory, we can have
the following:

- `./common/global` -> global configuration that is shared between all hosts and presets
- `./common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)
- `./common/users` -> user-specific configuration that is shared between hosts

#### Home Manager

The `/home` directory contains per-user, per-host Home Manager configurations. The directory
hierarchy corresponds to the user-specific Home Manager configurations for a particular host.

```
./home/<username>/<hostname>
```

In addition, the `./home` directory contains a `./common` subdirectory. This directory
contains Home Manager configurations that can be shared across all hosts. Within the `./common`
subdirectory, we have the following:

- `./common/global` -> global configuration that is shared between all hosts
- `./common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)

#### Modules

The `./modules` directory contains configuration to be used from the system configuration from
the flake (i.e. `darwinSystem`, `linuxSystem`, etc.).

## Secret Management

This project makes use of [Mozilla SOPS (Secrets OPerationS)](https://github.com/mozilla/sops)

The [`.sops.yaml`](./.sops.yaml) file at the root of the repository defines creation rules for
secrets to be encrypted with `sops`. Any files matching the defined creation rule paths will be
encrypted with the specified public keys.

### Updating Secrets

To update secrets, run `sops <path>` to open the secrets file in unencrypted edit mode,
and just save after updating. Helper `make` commands were added for ease of use. For example,
`make sops-secrets`.

If the file doesn't exist, it will be created. Make sure that a valid path regex exists in the
`.sops.yaml` file for the new file.

### Updating Secrets Configuration

The project uses [`sops-nix`](https://github.com/Mic92/sops-nix) for automatically decrypting
and injecting secrets into our NixOS configurations.

To update secret files after making changes to the `.sops.yaml` file, run the snippet below:

```bash
find . -regex $(yq -r '[.creation_rules[] | "./" + .path_regex] | join("\\|")' "$(pwd)/.sops.yaml") | \
xargs -I sops updatekeys -y {}
```

### Adding a Public Key

The easiest way to add new machines is by using SSH host keys. Use `age` to encrypt secrets.
To obtain an `age` public key, you can use the `ssh-to-age` tool to convert a host SSH Ed25519
key to the age format.

```bash
ssh-to-age -i ~/.ssh/id_ed25519.pub
```

Then add the `age` public key to the `.sops.yaml` file, apply it to the desired key groups,
and then re-encrypt the secret files (see [Updating Secrets Configuration](#updating-secrets-configuration)).

## Resources

- `nix-darwin` manual: https://daiderd.com/nix-darwin/manual/
- Remote Linux builder for macOS: https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder
