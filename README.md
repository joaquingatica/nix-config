# Joaquin's `nix-darwin` Configuration

Declarative configuration for my macOS machines, built on
[`nix-darwin`](https://github.com/nix-darwin/nix-darwin) for system settings and
[`home-manager`](https://github.com/nix-community/home-manager) for the user environment, with
secrets encrypted through [`sops-nix`](https://github.com/Mic92/sops-nix). Each machine gets its
own entry under `darwinConfigurations` in [`flake.nix`](./flake.nix); everything they share
lives in the `common` directories described in
[Directory Structure](#directory-structure).

## Setup Environment

### 0. Update configuration for new system

1. Add the host's base configuration under `./hosts`, named after the machine's hostname —
   either a flat `./hosts/<hostname>.nix` or a `./hosts/<hostname>/default.nix` folder if the
   host needs several files.
2. Add the matching Home Manager configuration at `./home/<username>/<hostname>.nix`, following
   the same convention.
3. Register both in `flake.nix`: add them to `darwinModules` and `homeModules`, then add a
   `darwinConfigurations.<hostname>` entry that composes the modules.

### 1. Setup `nix`

1. Run `curl -L https://nixos.org/nix/install | sh` to install Nix. On macOS this performs a
   multi-user installation, which `nix-darwin` requires: it creates the `nixbld` group and the
   `nix-daemon` service, and leaves `/nix/store` owned by `root:nixbld`.
2. In a new terminal, verify installation with `nix --version`
3. Enable flake support, so the `nix` commands in the next steps can evaluate this repository:

```shell
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Once `nix-darwin` is activated it manages `/etc/nix/nix.conf` from the `nix.settings` options in
[`hosts/common/global/nix.nix`](./hosts/common/global/nix.nix), which is where
`experimental-features` is set from then on. The user-level file written above is still read in
addition to it, so it does no harm, but it is only needed to bootstrap the first build and can
be removed afterwards.

See [the Nix installation guide](https://nix.dev/install-nix) for the full documentation.

### 2. Pre installation

#### 2.1. Create `~/.gnupg` folder

If `~/.gnupg` folder doesn't exist, create it: `mkdir ~/.gnupg`.

This is to work around a minor `gnupg` agent issue that [prints warnings if folder doesn't exist](https://github.com/NixOS/nixpkgs/issues/29331#issuecomment-685282396).

#### 2.2. Setup encryption keys

1. From the password manager, create the `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub` files.
2. Create the AGE keys file by running `ssh-to-age -i ~/.ssh/id_ed25519 -private-key > ~/.config/sops/age/keys.txt`

If at some point the SSH keys need to be recreated, run `ssh-keygen -t ed25519 -C "<email-here>"`.
Keep in mind to **not** set a passphrase for the key in order to be used from `home-manager`.

### 3. Setup repository & `nix-darwin`

1. Clone this repository in the folder: `~/.config`
2. In the cloned folder, run `sudo make install`
3. Run `direnv allow` to set up the project locally for development
4. Run `sudo make switch` to apply the configuration after the initial setup

Use `make install` only for that first activation: `darwin-rebuild` is not on `PATH` yet, so the
target fetches it with `nix run nix-darwin/master#darwin-rebuild` instead. Activation installs it
at `/run/current-system/sw/bin/darwin-rebuild`, and every later change goes through
`sudo make switch`, which calls that binary directly.

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

## Usage

- **Apply changes** from configuration: `sudo make switch`. The available system options are
  documented in the [`nix-darwin` manual](https://nix-darwin.github.io/nix-darwin/manual/).
- **Format** the project's source code: `make fmt`.
- **Edit secrets**: `make sops-*` commands provided in [`Makefile`](./Makefile).
- **Build for Linux**: `make darwin-run-builder` runs a
  [remote Linux builder for macOS](https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder)
  on demand, for building Linux derivations from this host. The declarative
  `nix.linux-builder` option in
  [`hosts/common/presets/darwin.nix`](./hosts/common/presets/darwin.nix) is disabled.

See [`Makefile`](./Makefile) for other commands.

## Directory Structure

The directory structure and documentation is inspired and based of off the [Effect-TS/infra](https://github.com/Effect-TS/infra/blob/cfcb7a25f066da20ca572b5ebf64d2faa7f6f74e/README.md)
repository.

The directory structure of this project is optimized for sharing configuration as much as possible.

### Hosts

The `./hosts` directory contains all systems that are managed by Nix Darwin. Each host is named
after the machine's hostname, and can be either a flat `<hostname>.nix` file or a `<hostname>/`
directory with a `default.nix` when the host's configuration warrants splitting up.

In addition, the `./hosts` directory contains a `./common` subdirectory. This directory contains
configuration that can be shared across all hosts. Within the `./common` subdirectory, we can have
the following:

- `./common/global` -> global configuration that is shared between all hosts and presets
- `./common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)
- `./common/users` -> user-specific configuration that is shared between hosts

### Home Manager

The `/home` directory contains per-user, per-host Home Manager configurations. The directory
hierarchy corresponds to the user-specific Home Manager configurations for a particular host,
and follows the same flat-file-or-folder convention as `./hosts`:

```
./home/<username>/<hostname>.nix
./home/<username>/<hostname>/default.nix
```

In addition, the `./home` directory contains a `./common` subdirectory. This directory
contains Home Manager configurations that can be shared across all hosts. Within the `./common`
subdirectory, we have the following:

- `./common/global` -> global configuration that is shared between all hosts
- `./common/presets` -> presets that are applied to specific host types (i.e. `nixos`, `darwin`, `desktop`, etc.)

### Modules

The `./modules` directory contains configuration to be used from the system configuration from
the flake (i.e. `darwinSystem`, `linuxSystem`, etc.).

## Secret Management

This project makes use of [Mozilla SOPS (Secrets OPerationS)](https://github.com/mozilla/sops)

The [`.sops.yaml`](./.sops.yaml) file at the root of the repository defines creation rules for
secrets to be encrypted with `sops`. Any files matching the defined creation rule paths will be
encrypted with the specified public keys.

### Updating Secrets

To update secrets, run `sops <path>` to open the secrets file in unencrypted edit mode,
and just save after updating. Helper `make` commands were added for ease of use:
`make sops-secrets` edits `hosts/common/global/secrets/secrets.yaml`, and `make sops-awscli`
edits `hosts/common/global/secrets/awscli.yaml`.

If the file doesn't exist, it will be created. Make sure that a valid path regex exists in the
`.sops.yaml` file for the new file. The current rules only match files inside a `secrets/`
directory under `hosts/` or `home/` — a file placed elsewhere is silently left unencrypted, so
add the rule before writing any secret into it.

### Updating Secrets Configuration

The project uses [`sops-nix`](https://github.com/Mic92/sops-nix) for automatically decrypting
and injecting secrets into our Nix configurations.

To re-encrypt every secret file after making changes to the `.sops.yaml` file, run the snippet
below. It uses `find -E` for extended regular expressions, since the BSD `find` shipped with
macOS defaults to basic ones and won't match the creation rules otherwise:

```bash
find -E . -regex "$(yq -r '[.creation_rules[] | "./" + .path_regex] | join("|")' "$(pwd)/.sops.yaml")" | \
xargs -I {} sops updatekeys -y {}
```

### Adding a Public Key

Secrets are encrypted to `age` recipients. Each entry under `keys` in `.sops.yaml` is the `age`
public key derived from the Ed25519 SSH key of a user on a given machine — the same key pair set
up in [Setup encryption keys](#22-setup-encryption-keys), not an SSH host key.

To derive the `age` public key, convert the SSH public key with `ssh-to-age`:

```bash
ssh-to-age -i ~/.ssh/id_ed25519.pub
```

Then add it to the `keys` list in `.sops.yaml`, reference it from the desired key groups, and
re-encrypt the secret files (see [Updating Secrets Configuration](#updating-secrets-configuration)).
The re-encryption has to be run from a machine that can already decrypt them, since `sops`
decrypts each file before writing it back out to the new recipient list.
