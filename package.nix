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
  version = "1.0.15";

  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin" = "darwin-x64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  nativeHashes = {
    "darwin-arm64" = "1paspqbq5lnna8gxs53bds87zd2yi44xq91y5lq0fqr9ryafmdkl";
    "darwin-x64" = "0vs2m5yzmgwjkba41fjlz4ndmh7bvlh3gr665jd9fyd9s06rkspx";
    "linux-x64" = "08mjgc4c7m0wys0dy0dayb8bgmgraihi0b8hxbg5m6xzh3nrqs2a";
    "linux-arm64" = "1lhhxrdjhvjx275nr9qy82g822j8v1pxfp4r43pxpri76c9scan4";
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
