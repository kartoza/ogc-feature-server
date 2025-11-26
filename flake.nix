{
  description = "OGC Features API Server with pygeoapi";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          pip
          virtualenv
        ]);
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            curl
            jq
          ];
          
          shellHook = ''
            echo "OGC Features API development environment"
            echo "Virtual environment will be managed by direnv"
            echo "Available commands:"
            echo "  python run_server.py  - Start the server"
            echo "  curl http://localhost:5000  - Test the server"
          '';
        };
        
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ogc-feature-server";
          version = "1.0.0";
          
          src = ./.;
          
          buildInputs = [ pythonEnv ];
          
          installPhase = ''
            mkdir -p $out/bin $out/share/ogc-feature-server
            cp -r * $out/share/ogc-feature-server/
            cat > $out/bin/ogc-feature-server << EOF
            #!${pkgs.bash}/bin/bash
            cd $out/share/ogc-feature-server
            ${pythonEnv}/bin/python run_server.py
            EOF
            chmod +x $out/bin/ogc-feature-server
          '';
        };
      });
}