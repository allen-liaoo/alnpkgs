{
  rustPlatform,
  lib,
  openssl,
  pkg-config,
  typst,
}:

rustPlatform.buildRustPackage {
  pname = "typst-docs-assets";
  version = typst.version;

  src = typst.src;
  cargoLock = {
    lockFile = "${typst.src}/Cargo.lock";
    outputHashes = {
      # typst-dev-assets is versioned with typst; update the hash when typst is bumped
      "typst-dev-assets-${typst.version}" = "sha256-1ICmdrTcC2v5MdONrrvWetCExHe9nYYwqghRCrM5lOs=";
    };
  };

  nativeBuildInputs = [
    openssl
    pkg-config
  ];

  env = {
    OPENSSL_NO_VENDOR = 1;
    PKG_CONFIG_PATH = "${lib.getDev openssl}/lib/pkgconfig";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cargo run --package typst-docs -- --assets-dir $out --out-file $out/main.json 
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Generated typst documentation assets";
    license = lib.licenses.asl20;
  };
}
