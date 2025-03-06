{
  description = "amazon corretto flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: 

    let
      supportedSystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      allSystemDerivations =  nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          derivation = import ./default.nix { inherit pkgs; };
        in {
          default = derivation;
        }
      );
    in {
      packages = allSystemDerivations;
    };
  
}
