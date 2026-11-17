{
  description = "SessionML - affine session types in OCaml";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pin the OCaml compiler family to 5.4.
      ocaml = pkgs.ocaml-ng.ocamlPackages_5_4;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          ocaml.ocaml
          ocaml.dune_3
          ocaml.findlib

          # Interactive development
          ocaml.utop
          ocaml.ocaml-lsp
          ocaml.ocamlformat

          # Testing
          (pkgs.lib.getDev ocaml.qcheck)
        ];
      };
    };
}

