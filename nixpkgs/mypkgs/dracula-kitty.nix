{ stdenv, fetchFromGitHub }:

# https://github.com/dracula/kitty
stdenv.mkDerivation {
  pname = "dracula-kitty";
  version = "2021.09.18";

  src = fetchFromGitHub {
    owner = "dracula";
    repo = "kitty";
    rev = "eeaa86a730e3d38649053574dc60a74ce06a01bc";
    sha256 = "0mxj1i2ab9lcrmw34fxbqkbsn728w63pzr3jdxxqnb97zixvja6z";
  };

  installPhase = ''
    cp -r ./ $out/
  '';
}