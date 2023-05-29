{ pkgs, lib }:

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

    buildInputs = with pkgs; [ xeus nlohmann_json cppzmq xtl libuuid ];

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
    # "LUA_REQUIRED_VERSION=5.1.4"
    # "DXEUS_LUA_BUILD_STATIC=OFF"
    # "DLUA_LIBRARIES=${pkgs.luajit}/bin/lua"
  ];

  # LUA_LIBRARIES="${pkgs.luajit}";

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
}
