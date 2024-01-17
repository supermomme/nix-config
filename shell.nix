{ pkgs ? import <nixpkgs> {} }:
let
  build = flake: ssh: pkgs.writeShellScriptBin "build-${flake}" ''
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --fast --use-remote-sudo --flake .#${flake} --target-host ${ssh} --build-host ${ssh}
  '';
in pkgs.mkShell {
  buildInputs = with pkgs.buildPackages; [
    (build "spiffy" "momme@100.120.137.91")
    (build "drippy" "momme@100.118.222.97")
  ];
  packages = [
    pkgs.cfssl
    pkgs.nixos-rebuild
  ];
}