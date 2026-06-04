{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  nodejs_22,
}:
buildNpmPackage (finalAttrs: {
  pname = "gulp-cli";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "gulpjs";
    repo = "gulp-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eLorGF/aZwzi+c6sabmgkqvryNtznt3mJVc/Vmfa9aE=";
  };

  nodejs = nodejs_22;
  nativeBuildInputs = [jq];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    # The published tarball ships a prebuilt gulp.1 manpage that is not in
    # the git source. Drop the man entry so npm pack does not look for it.
    jq 'del(.man) | .files |= map(select(. != "gulp.1"))' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  npmDepsHash = "sha256-GQmVIkKYlsRXZLS4WLk47hmn87tmIu+AwShkzkK0Ih8=";

  dontNpmBuild = true;
  dontNpmPrune = true;
})
