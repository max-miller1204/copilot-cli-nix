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
  version = "1.0.14";

  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin" = "darwin-x64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  nativeHashes = {
    "darwin-arm64" = "0i6jpbvmmbcnq2w3iagqa5gkd2jhinqrblalq3ia5sy18bam8wdz";
    "darwin-x64" = "0hi8x65ibk12vmqq3qxy63h2b6l6p095w0c870gz0ipkyaw9fk8g";
    "linux-x64" = "0awqajigb0jv912xq412l56qrvbnmiwyih46rbgxx9bn4xcrr934";
    "linux-arm64" = "1v2wfcg9n6kjj7qi4yxzlrvaay17ffkv18x8kn6y5nqszxz8lp3y";
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
