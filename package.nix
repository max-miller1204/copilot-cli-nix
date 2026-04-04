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
  version = "1.0.18";

  platformMap = {
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-darwin" = "darwin-x64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };

  platform = platformMap.${stdenv.hostPlatform.system} or null;

  nativeHashes = {
    "darwin-arm64" = "1512vyxc2q86lf4sv7pyxlrad6zpwlkm645gnnwhbrh8jwjgpb16";
    "darwin-x64" = "1b8cbwdad35lwc4i7rrx4f7vfbw7vljr289352lkq8xfziqpqgk6";
    "linux-x64" = "04vr0g5nzrp1f3fimrzsjp531an5ri981y2hjbplznx30fxkpjky";
    "linux-arm64" = "0qm0pl77p9w9mh98vi8ynsyg15y353b920f42j428gwh6fzqfyih";
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
