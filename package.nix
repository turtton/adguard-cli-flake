{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  versionData = lib.importJSON ./hashes.json;
  version = versionData.version;
  system = stdenvNoCC.hostPlatform.system;

  srcInfo =
    versionData.sources.${system}
    or (throw "Unsupported system: ${system}. Supported systems: ${builtins.toString (builtins.attrNames versionData.sources)}");

  src = fetchurl {
    url = srcInfo.url;
    hash = srcInfo.hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "adguard-cli";
  inherit version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/adguard-cli $out/bin

    # Extract tarball (top-level dir has variable name, strip it)
    tar -xzf ${src} -C $out/share/adguard-cli --strip-components=1

    # Install helper tools
    for helper in adguard_cli_nm adguard_root_helper certutil; do
      if [ -f "$out/share/adguard-cli/$helper" ]; then
        chmod +x "$out/share/adguard-cli/$helper"
      fi
    done

    # Shell completion
    if [ -f "$out/share/adguard-cli/bash-completion.sh" ]; then
      install -Dm644 "$out/share/adguard-cli/bash-completion.sh" \
        "$out/share/bash-completion/completions/adguard-cli"
    fi

    # Main binary symlink
    ln -s "$out/share/adguard-cli/adguard-cli" "$out/bin/adguard-cli"

    runHook postInstall
  '';

  meta = {
    description = "AdGuard CLI — ad blocking in your terminal";
    homepage = "https://github.com/AdguardTeam/AdGuardCLI";
    changelog = "https://github.com/AdguardTeam/AdGuardCLI/releases";
    downloadPage = "https://github.com/AdguardTeam/AdGuardCLI/releases";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames versionData.sources;
    mainProgram = "adguard-cli";
  };
}
