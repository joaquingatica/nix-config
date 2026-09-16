# AGENTS.md

This repository is Joaquin's `nix-darwin` + `home-manager` configuration. It is applied to the
macOS machine you are running on — a bad change here breaks the developer's own environment.

[`README.md`](./README.md) documents the directory structure, the `make` targets, and how
`sops` secrets are managed. Read it first; this file covers only what it leaves out.

There is no issue tracker for this repo. Write commits and PRs without a ticket reference.

## Working on this repo

`nix` evaluation and builds here are slow (minutes); prefer a longer explicit `timeout` over a
retry.

Do not run `sudo make switch` on the developer's behalf unless they ask for it. To check a
change without applying it, evaluate the option directly:

```shell
nix eval --json '.#darwinConfigurations."ang-joaquin-mbp14".config.home-manager.users.joaquin.programs.git.enable'
```

Or build the whole system closure without activating it:

```shell
nix build '.#darwinConfigurations.ang-joaquin-mbp14.system' --no-link
```

Run `make fmt` before committing. It shells out to `pre-commit`, so it needs the dev shell
(`direnv allow`, or `nix develop`); `.pre-commit-config.yaml` is a symlink into the Nix store
and is gitignored.

Never write plaintext into a secrets file, and never print a decrypted secret into the
conversation. Edit secrets only through `sops` / the `make sops-*` targets.

## Conventions

- `alejandra` formatting for Nix — let `make fmt` do it rather than hand-formatting.
- Module headers use the terse arg pattern in use across the repo: `{...}: {` when no args are
  needed, and destructure only what the module actually references.
- `.editorconfig` governs indentation: 2 spaces for `.nix`, `.yaml`, `.json`, `.md`; tabs in
  `Makefile`; 100-column lines.
- Comments explain _why_. The existing ones are good models — they cite an upstream issue, a
  macOS quirk, or the reason an obvious approach fails, and say when they can be removed.
- Commits follow Conventional Commits, lowercase and imperative, usually subject-only
  (`fix: stop darwin activation from fighting nix-homebrew taps`). No tracker token.
- Pinned versions (Homebrew taps, `nixpkgs` channels) update through `flake.lock`, not by
  running `brew update` — `homebrew.onActivation.autoUpdate` is deliberately off.
