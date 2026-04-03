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
  version = "1.0.17";

  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin" = "darwin-x64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  nativeHashes = {
    "darwin-arm64" = "1dykbz76cixbkph5cahm0cgrrd68myjkj0badgzn6q3ddb9ni89c";
    "darwin-x64" = "1wgaxagma51advikf9wq2jpgbr9gqbicyyv87nvas7i9nmz10yyb";
    "linux-x64" = "0n3zwklv6vz88v5kcjvwaa5wzaw49cp8jdfrfbm0dax85ikc76bc";
    "linux-arm64" = "13sknrcwr7p10066394sfdk5p1n47kpr9k0a2wm9n1mpvxxjjc45";
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
