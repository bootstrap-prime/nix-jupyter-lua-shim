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
      let pkgs = import inputs.master {
            inherit system;
            # overlays = [ (new: old: {
            #   xeus = newpkgs.xeus;
            #   xtl = newpkgs.xtl;
            # }) ];
          };
          # newpkgs = import inputs.master { inherit system; };

      in rec {

        devShell = let
          kernels = [ (pkgs.callPackage ./default.nix {}) ];
          # additionalExtensions = [
          #   "widgetsnbextension"
          # ];

          pythonEnv = let
            jupyterlab-widgets = (pkgs.python310Packages.jupyterlab-widgets.overridePythonAttrs (old: rec {
                pname = "jupyterlab-widgets";
                version = "1.1.4";
                src = pkgs.python310Packages.fetchPypi {
                  pname = "jupyterlab_widgets";
                  inherit version;
                  sha256 = "sha256-6m52EnJelNCWbWTGNEkQaG9L+GEFM81A2uummAZZsU0=";
                };
            }));
            # notebook = (pkgs.python310Packages.widgetsnbextension.overridePythonAttrs (old: rec {
            #   version = "4.4.1";
            #   src = pkgs.python310Packages.fetchPypi {
            #     pname = "notebook";
            #     inherit version;
            #     sha256 = "sha256-rRNWxXXVrdkIr+iGJV3q+z+bFYkUapknnR3LpaBdFqU=";
            #   };
            # }));
            # widgetsnbextension = (pkgs.python310Packages.widgetsnbextension.overridePythonAttrs (old: rec {
            #   version = "3.6.4";
            #   src = pkgs.python310Packages.fetchPypi {
            #     pname = "widgetsnbextension";
            #     inherit version;
            #     sha256 = "sha256-rRNWxXXVrdkIr+iGJV3q+z+bFYkUapknnR3LpaBdFqU=";
            #   };
            # }));
            # ipywidgets = (pkgs.python310Packages.ipywidgets.overridePythonAttrs (old: rec {
            #   version = "7.7.5";
            #   src = pkgs.python310Packages.fetchPypi {
            #     pname = "ipywidgets";
            #     inherit version;
            #     sha256 = "sha256-I5KUPtMCU8hKw28j9wf6HJ00RhrlNWlESBqE1bCNabI=";
            #   };
            #   propagatedBuildInputs = with pkgs.python310Packages; [
            #     ipython
            #     ipykernel
            #     jupyterlab-widgets
            #     traitlets
            #     nbformat
            #     pytz
            #     widgetsnbextension
            #   ];
            # }));
          in (pkgs.python3.withPackages (ps:
            with ps; [
              # jupyter
              jupyterlab
              importlib-metadata
              numpy
              scipy
              matplotlib
              # ipywidgets
              widgetsnbextension
              # jupyter_core
              jupyterlab-widgets
              # numpy
              # pandas
              # ipympl
            ]));
          jupyterlab = pkgs.python310Packages.jupyterlab;
        in pkgs.mkShell rec {
          buildInputs = with pkgs.python310Packages;
            [
              pythonEnv
              # jupyterlab
              # importlib-metadata
              # numpy
              # scipy
              # matplotlib
              # # ilua
              pkgs.luajit
              pkgs.luajitPackages.lpeg
              pkgs.nodejs
              # ipywidgets
              # widgetsnbextension
              # jupyterlab-widgets
              # ipydatawidgets
              # numpy pandas
              # matplotlib plotly dash
            ] ++ kernels;

          # labextensions
          # ${pkgs.lib.concatMapStrings
          #      (s: "jupyter labextension enable --no-build --app-dir=$TEMPDIR ${s}; ")
          #      (pkgs.lib.unique
          #        ((pkgs.lib.concatMap
          #            (d: pkgs.lib.attrByPath ["passthru" "jupyterlabExtensions"] [] d)
          #            buildInputs) ++ additionalExtensions))  }
          # jupyter lab build --app-dir=$TEMPDIR
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

      }); # // {
}
