{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, glibc
, gcc-unwrapped
, gnutar
, gzip
}:

let
  version = "1.0.16";

  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin" = "darwin-x64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  nativeHashes = {
    "darwin-arm64" = "05bghd639f4ajskvdp2wgwrz8n0in1120cayqf9hdq8ga008pp57";
    "darwin-x64" = "0k2bcqr0qjw6yg2lrl1y0p2fa5wi4z2ipf31q8mjaig4p6azxha6";
    "linux-x64" = "10qk3w62a822ax7q5mqw1yna4vwkhrbn7a1akzm21ps86hnjy55p";
    "linux-arm64" = "1l7m3d87q9fpn1y9x3kg6vs1swcrzy4m71igklbn2mjk33z39hp8";
  };

  src = fetchurl {
    url = "https://github.com/github/copilot-cli/releases/download/v${version}/copilot-${platform}.tar.gz";
    sha256 = nativeHashes.${platform};
  };
in
assert platform != null ||
  throw "Unsupported platform: ${stdenv.hostPlatform.system}. Supported: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux";

stdenv.mkDerivation {
  pname = "github-copilot-cli";
  inherit version;

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ gnutar gzip ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glibc
    gcc-unwrapped.lib
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    tar -xzf ${src} -C build
    chmod u+w,+x build/copilot
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp build/copilot $out/bin/copilot
    chmod +x $out/bin/copilot
    runHook postInstall
  '';

  meta = with lib; {
    description = "GitHub Copilot CLI - AI-powered coding assistant in your terminal";
    homepage = "https://github.com/github/copilot-cli";
    license = licenses.unfree;
    platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "copilot";
  };
}
