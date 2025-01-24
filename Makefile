.PHONY: install boot switch fmt darwin-run-builder sops-nix-env-vars sops-secrets sops-awscli

# https://gist.github.com/sighingnow/deee806603ec9274fd47
OS_NAME := $(shell uname -s | tr A-Z a-z)

install:
ifeq ($(OS_NAME), darwin)
	nix run nix-darwin -- switch --flake ./
endif

switch:
ifeq ($(OS_NAME), darwin)
	darwin-rebuild switch --option extra-builtins-file $$PWD/extra-builtins.nix --flake ./
endif

fmt:
	pre-commit run --all-files

darwin-run-builder:
	nix run nixpkgs#darwin.linux-builder

sops-nix-env-vars:
	sops hosts/common/global/secrets/nix-env-vars.json

sops-secrets:
	sops home/joaquin/common/global/secrets/secrets.yaml

sops-awscli:
	sops home/joaquin/common/global/secrets/awscli.yaml
