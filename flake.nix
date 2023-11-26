{
  description = "Incubator dev-shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, fenix }:
  flake-utils.lib.eachDefaultSystem (system:
    let pkgs = (import "${nixpkgs}" {
      inherit system;
      config.allowUnfree = true; #ngrox
    });
  in {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        awscli2
        terraform
        terragrunt
        tfautomv
        ssm-session-manager-plugin
      ];
      GIT_TEMPLATE_DIR="";
    };
  });
}
