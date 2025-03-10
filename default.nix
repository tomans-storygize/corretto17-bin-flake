{ pkgs ? import <nixpkgs> {} }:

let
  data = import ./data.nix {};
  fetchurl = pkgs.fetchurl;
  stdenv = pkgs.stdenv;
  lib = pkgs.lib;
  installShellFiles = pkgs.installShellFiles;
  autoPatchelfHook = pkgs.autoPatchelfHook;
  makeWrapper = pkgs.makeWrapper;

in stdenv.mkDerivation {
  pname = "corretto21-bin";
  inherit (data) version;

  postUnpack = ''
    # ls
  '';

  srcs = map fetchurl data.correttoPkgs.${stdenv.hostPlatform.system};

  home = ''${placeholder "out"}'';

  installPhase = ''
    mkdir -p $out;
  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    cp -R * $out/
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    cp -R ./Contents/Home/* $out/
  '' + ''
    # any unconditional steps here
    mkdir -p $out/nix-support
    cat <<EOF > $out/nix-support/setup-hook
    if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
    EOF
  '';

  # env = {
  #   JAVA_HOME = "$out";
  #   PATH = "$JAVA_HOME/bin:$PATH";
  # };

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook makeWrapper ];
  buildInputs = [ pkgs.jdk21 stdenv.cc.cc.libgcc or null ];

  meta = with lib; {
    homepage = "https://docs.aws.amazon.com/corretto/latest";
    description = "jdk with changes from amazon";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = with licenses; [ gpl2 ];
    platforms = builtins.attrNames data.correttoPkgs;
    maintainers = with maintainers; [
      tomans-storygize
    ];
    hydraPlatforms = [ ]; # Hydra fails with "Output limit exceeded"
  };
}
