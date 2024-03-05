{
  description = "Safe application helm charts";

  inputs = {
    flake-parts.url = github:hercules-ci/flake-parts;
    nixpkgs.url = github:NixOS/nixpkgs/master;
  };

  outputs = { self, nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { config, lib, self', inputs', system, ... }:
        let
          overlays = [];
          pkgs = import nixpkgs {
            inherit system overlays;
          };

          # utils
          utilsPkgs = with pkgs; [
            yamllint
            yamlfix
            yq-go
          ];

          k8sPkgs = with pkgs; [
            (pkgs.wrapHelm pkgs.kubernetes-helm {
              plugins = [
                pkgs.kubernetes-helmPlugins.helm-diff
              ];
            })
          ];

          buildDevShell = pkgs.mkShell {
            packages = utilsPkgs ++ k8sPkgs;
          };
          defaultDevShell = buildDevShell;
        in
        {
          devShells.default = defaultDevShell;
        };
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      flake = { };
    };
}
