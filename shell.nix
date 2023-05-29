{ pkgs ? import <nixpkgs> { }, unstablepkgs ? import <nixos> {  } }:

let
  kernels = [ (pkgs.callPackage ./default.nix { })
            ];
  # additionalExtensions = [
  #   "widgetsnbextension"
  # ];

  pythonEnv =
    (pkgs.python3.withPackages (ps: with ps;[
      jupyter
      jupyterlab
      importlib-metadata
      numpy
      scipy
      matplotlib
      ipywidgets
      widgetsnbextension
      jupyter_core
      jupyterlab-widgets
      numpy
      pandas
      ipympl
    ]));
  jupyterlab = pkgs.python310Packages.jupyterlab;
in pkgs.mkShell rec {
  buildInputs = with pkgs.python310Packages; [
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
  ] ++ kernels ;


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
    export JUPYTER_PATH="${pkgs.lib.concatMapStringsSep ":" (p: "${p}/share/jupyter/") kernels}"


# start jupyterlab
jupyter lab --app-dir=$TEMPDIR

  '';
}
