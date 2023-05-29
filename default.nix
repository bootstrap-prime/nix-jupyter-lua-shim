{ lib, python310, python310Packages }:

python310.pkgs.buildPythonPackage rec {
  pname = "jupyterlite-xeus-lua";
  version = "0.3.3";

  buildInputs = with python310Packages; [ jupyter-packaging ];
  propagatedBuildInputs = buildInputs;

  src = python310.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ExtjFcdZtSXJKPv2cWzmRU5Ii8YVTaL5wx5f4U/gKT8=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/jupyter-xeus/xeus-lua";
    description =
      "a lua kernel for jupyter";
    license = licenses.bsd3;
    maintainers = with maintainers; [ bootstrap-prime ];
  };
}
