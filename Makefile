.PHONY: install boot switch fmt darwin-run-builder sops-secrets sops-awscli

# https://gist.github.com/sighingnow/deee806603ec9274fd47
OS_NAME := $(shell uname -s | tr A-Z a-z)

install:
ifeq ($(OS_NAME), darwin)
	nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake ./
endif

switch:
ifeq ($(OS_NAME), darwin)
	darwin-rebuild switch --option extra-builtins-file $$PWD/extra-builtins.nix --flake ./
endif

fmt:
	pre-commit run --all-files

darwin-run-builder:
	nix run nixpkgs#darwin.linux-builder

sops-secrets:
	sops home/joaquin/common/global/secrets/secrets.yaml

sops-awscli:
	sops home/joaquin/common/global/secrets/awscli.yaml
