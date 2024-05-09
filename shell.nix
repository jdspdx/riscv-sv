{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.neovim
    pkgs.svls
    pkgs.verilator
  ];
}
