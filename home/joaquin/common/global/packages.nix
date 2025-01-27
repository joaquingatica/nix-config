{pkgs, ...}: {
  home.packages = with pkgs; [
    awscli2
    docker
    docker-compose
    gnupg
    grpcurl
    kubectl
    kubernetes-helm
    nodejs
    nodePackages.gulp-cli
    nodePackages.vercel
    pre-commit
    python3
    terraform
    yarn
    yq
  ];
}
