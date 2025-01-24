.PHONY: install switch fmt run-builder sops-nix-env-vars sops-secrets sops-awscli

# install nix-darwin
install:
	nix run nix-darwin -- switch --flake .

# rebuild/apply changes to darwin configuration
switch:
	darwin-rebuild switch --option extra-builtins-file $$PWD/extra-builtins.nix --flake .

fmt:
	pre-commit run --all-files

# manually run linux builder
run-builder:
	nix run nixpkgs#darwin.linux-builder

sops-nix-env-vars:
	sops hosts/common/global/secrets/nix-env-vars.json

sops-secrets:
	sops home/joaquin/common/global/secrets/secrets.yaml

sops-awscli:
	sops home/joaquin/common/global/secrets/awscli.yaml

public-pull:
	git subtree pull --prefix public https://github.com/joaquingatica/nix-config.git main  --squash
