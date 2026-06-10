# NOTE: this will be no longer needed if the following PR
# is merged and released: https://github.com/NixOS/nixpkgs/pull/528117
{
  buildNpmPackage,
  fetchFromGitHub,
  runCommand,
  jq,
}: let
  pname = "gulp-cli";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "gulpjs";
    repo = "gulp-cli";
    tag = "v${version}";
    hash = "sha256-eLorGF/aZwzi+c6sabmgkqvryNtznt3mJVc/Vmfa9aE=";
  };

  # The published package includes a prebuilt `gulp.1` manpage that is not in
  # the git source. The man entry is removed so `npm pack` does not look for it.
  patchedPackageJSON = runCommand "package.json" {nativeBuildInputs = [jq];} ''
    jq 'del(.man) | .files |= map(select(. != "gulp.1"))' ${src}/package.json > $out
  '';
in
  buildNpmPackage (finalAttrs: {
    inherit pname version src;

    __structuredAttrs = true;

    postPatch = ''
      cp ${patchedPackageJSON} package.json
      # Upstream source does not include a package-lock.json, so it was regenerated
      # via `npm install --package-lock-only` at this tag
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-GQmVIkKYlsRXZLS4WLk47hmn87tmIu+AwShkzkK0Ih8=";

    dontNpmBuild = true;

    dontNpmPrune = true;
  })
