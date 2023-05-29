{
  description = "flake for running a lua jupyter notebook";

  inputs = {
    master = { url = "github:nixos/nixpkgs"; };
    # nixpkgs.url = "github:nixos/nixpkgs/21.05";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = inputs@{ self, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import inputs.master { inherit system; };

      in rec {
        packages.default =
          let
            xeus-zmq = pkgs.stdenv.mkDerivation rec {
              pname = "xeus-zmq";
              version = "1.0.1";

              src = pkgs.fetchFromGitHub {
                owner = "jupyter-xeus";
                repo = "xeus-zmq";
                rev = "${version}";
                sha256 = "JLxDQZjkVid4WQfHRRk3dLdZrMvhpnVq3u5UrRn5n9Y=";
              };

              buildInputs = with pkgs; [
                pkgs.xeus
                openssl
                zmqpp
                nlohmann_json
                xproperty
                xwidgets
                cppzmq
                xtl
                libuuid
              ];

              nativeBuildInputs = with pkgs; [ cmake ];
            };
            xcanvas = pkgs.stdenv.mkDerivation rec {
              pname = "xeus-xcanvas";
              version = "0.3.0";

              src = pkgs.fetchFromGitHub {
                owner = "jupyter-xeus";
                repo = "xcanvas";
                rev = "${version}";
                sha256 = "5lyiXqk/P6hvYAKTMctRIjdeMpvxfI1RRWVMU//Rg0E=";
              };

              buildInputs = with pkgs; [
                xeus
                nlohmann_json
                xproperty
                xwidgets
                xeus-zmq
                cppzmq
                zeromq
                openssl
                xtl
                libuuid
              ];

              nativeBuildInputs = with pkgs; [ cmake ];
            };

            xproperty = pkgs.stdenv.mkDerivation rec {
              pname = "xeus-xproperty";
              version = "0.11.0";

              src = pkgs.fetchFromGitHub {
                owner = "jupyter-xeus";
                repo = "xproperty";
                rev = "${version}";
                sha256 = "X0Ryc3wSqYzXLHbN63yglhB8FjCePv67KH0tHl24WQo=";
              };

              buildInputs = with pkgs; [
                xeus
                nlohmann_json
                cppzmq
                xtl
                libuuid
              ];

              nativeBuildInputs = with pkgs; [ cmake ];
            };

            xwidgets = pkgs.stdenv.mkDerivation rec {
              pname = "xeus-xwidgets";
              version = "0.27.0";

              src = pkgs.fetchFromGitHub {
                owner = "jupyter-xeus";
                repo = "xwidgets";
                rev = "${version}";
                sha256 = "HN1SLPXyGlLpKdGZc4OfdkGznwcFGmQ2GZrdsi5k9aQ=";
              };

              buildInputs = with pkgs; [
                xeus
                nlohmann_json
                xproperty
                cppzmq
                xtl
                libuuid
              ];

              nativeBuildInputs = with pkgs; [ cmake ];
            };
          in pkgs.stdenv.mkDerivation {
            pname = "xeus-lua";
            version = "2023-05-28";

            src = pkgs.fetchFromGitHub {
              owner = "jupyter-xeus";
              repo = "xeus-lua";
              rev = "48e024cb86f1fb2a984811b12b968fb1677cfa18";
              sha256 = "THWAded5pgbtieHjIgV/4KEfj8uCb/oPyBAB20lOQ8w=";
            };

            nativeBuildInputs = with pkgs; [ cmake pkg-config ];

            patches = [ ./fix_tablepack.patch ];

            cmakeFlags = [
              "-DXEUS_LUA_USE_LUAJIT=ON"
              "-DXLUA_WITH_XCANVAS=ON"
              "-DXLUA_WITH_XWIDGETS=ON"
            ];

            buildInputs = with pkgs; [
              pkgs.xeus
              xcanvas
              xwidgets
              nlohmann_json
              cppzmq
              xtl
              pkgs.luajit_2_0
              libuuid
              openssl
              xeus-zmq
              zmqpp
              xproperty
            ];

          };

        # inspired by https://github.com/bear5-lab/nixroot/blob/5b8d5a9382db048133479a87a61bccae8d69f03d/shells/jupyterWith/customized_shell.nix
        devShell = let
          kernels = [ packages.default ];

          pythonEnv = let
            jupyterlab-widgets =
              (pkgs.python310Packages.jupyterlab-widgets.overridePythonAttrs
                (old: rec {
                  pname = "jupyterlab-widgets";
                  version = "1.1.4";
                  src = pkgs.python310Packages.fetchPypi {
                    pname = "jupyterlab_widgets";
                    inherit version;
                    sha256 =
                      "sha256-6m52EnJelNCWbWTGNEkQaG9L+GEFM81A2uummAZZsU0=";
                  };
                }));
          in (pkgs.python3.withPackages (ps:
            with ps; [
              jupyterlab
              importlib-metadata
              numpy
              scipy
              matplotlib
              widgetsnbextension
              jupyterlab-widgets
            ]));
          jupyterlab = pkgs.python310Packages.jupyterlab;
        in pkgs.mkShell rec {
          buildInputs = with pkgs.python310Packages;
            [ pythonEnv pkgs.luajit pkgs.luajitPackages.lpeg pkgs.nodejs ]
            ++ kernels;

          shellHook = ''
                mkdir -p $TEMPDIR
                cp -r ${jupyterlab}/share/jupyter/lab/* $TEMPDIR
                chmod -R 755 $TEMPDIR
                echo "$TEMPDIR is the app directory"

                # kernels
                export JUPYTER_PATH="${
                  pkgs.lib.concatMapStringsSep ":" (p: "${p}/share/jupyter/")
                  kernels
                }"

            # start jupyterlab
            jupyter lab --app-dir=$TEMPDIR
          '';
        };
      });
}
