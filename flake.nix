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
            hurl
            gdal
            proj
            geos
            sqlite
            gcc
            stdenv.cc.cc.lib
          ];
          
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.geos}/lib:${pkgs.proj}/lib:${pkgs.gdal}/lib:$LD_LIBRARY_PATH"
            export GDAL_DATA="${pkgs.gdal}/share/gdal"
            export PROJ_LIB="${pkgs.proj}/share/proj"
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
        
        packages.test = pkgs.writeShellScriptBin "ogc-api-test" ''
          echo "🧪 Testing OGC Features API with Hurl"
          echo "Make sure the server is running on http://localhost:5000"
          echo ""
          ${pkgs.hurl}/bin/hurl --test ${./tests/ogc-api-tests.hurl}
        '';
        
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/ogc-feature-server";
        };
        
        apps.test = {
          type = "app";
          program = "${self.packages.${system}.test}/bin/ogc-api-test";
        };
      });
}