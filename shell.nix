{ pkgs ? import <nixpkgs> { } }:

# based on https://github.com/bear5-lab/nixroot/blob/5b8d5a9382db048133479a87a61bccae8d69f03d/shells/jupyterWith/customized_shell.nix

let
  kernels = [ (pkgs.callPackage ./default.nix { }) pkgs.python310Packages.ilua ];
in pkgs.mkShell rec {
  buildInputs = with pkgs.python310Packages; [
    jupyterlab
    importlib-metadata
    numpy
    scipy
    matplotlib
    # ilua
    pkgs.lua
    pkgs.nodejs
    ipywidgets
  ] ++ kernels ;


  shellHook = ''

    mkdir -p $TEMPDIR
    cp -r ${pkgs.python310Packages.jupyterlab}/share/jupyter/lab/* $TEMPDIR
    chmod -R 755 $TEMPDIR
    echo "$TEMPDIR is the app directory"

    # kernels
    export JUPYTER_PATH="${pkgs.lib.concatMapStringsSep ":" (p: "${p}/share/jupyter/") kernels}"

# labextensions
${pkgs.lib.concatMapStrings
     (s: "jupyter labextension install --no-build --app-dir=$TEMPDIR ${s}; ")
     (pkgs.lib.unique
       ((pkgs.lib.concatMap
           (d: pkgs.lib.attrByPath ["passthru" "jupyterlabExtensions"] [] d)
           buildInputs)))  }
jupyter lab build --app-dir=$TEMPDIR

# start jupyterlab
jupyter lab --app-dir=$TEMPDIR

  '';
}
