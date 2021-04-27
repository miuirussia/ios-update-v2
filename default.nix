with (import <nixpkgs> {});

let
  modules = mkYarnModules {
    name = "ios-update-modules";
    pname = "ios-update-v2";
    version = "0.0.1";
    packageJSON = ./package.json;
    yarnLock = ./yarn.lock;
    yarnFlags = [
      "--offline"
      "--frozen-lockfile"
      "--ignore-engines"
    ];
  };
in stdenv.mkDerivation {
  name = "ios-update-v2";
  src = ./.;

  buildInputs = [ makeWrapper ];

  phases = ["unpackPhase" "buildPhase" "installPhase"];

  buildPhase = ''
    ln -s ${modules}/node_modules ./node_modules
    ${yarn}/bin/yarn build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./index.js $out/index.js
    makeWrapper ${nodejs}/bin/node $out/bin/ios-update-v2 --add-flags "$out/index.js"
    ln -s ${modules}/node_modules $out/node_modules
  '';
}
