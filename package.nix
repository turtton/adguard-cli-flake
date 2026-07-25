{
  lib,
  stdenvNoCC,
  fetchurl,
  bash,
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

    # Fix hardcoded /bin/bash shebang (does not exist on NixOS)
    substituteInPlace $out/share/adguard-cli/install_cert.sh \
      --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'
    # Don't abort when no FHS system cert dir exists (NixOS);
    # skip the system trust store and still install into browser profiles
    patch -d $out/share/adguard-cli -p1 < ${./patches/install_cert-nixos.patch}
    chmod +x $out/share/adguard-cli/install_cert.sh

    # Install helper tools
    for helper in adguard_cli_nm adguard_root_helper certutil; do
      if [ -f "$out/share/adguard-cli/$helper" ]; then
        chmod +x "$out/share/adguard-cli/$helper"
      fi
    done

    # The root helper must be a SUID-root binary, which is impossible in the
    # read-only Nix store. Keep the real binary under a hidden name and make
    # the expected path a symlink to the NixOS security.wrappers location
    # (provided by nixosModules.adguard-cli). On non-NixOS hosts the symlink
    # dangles and automatic mode stays unavailable, as before.
    if [ -f "$out/share/adguard-cli/adguard_root_helper" ]; then
      mv $out/share/adguard-cli/adguard_root_helper \
         $out/share/adguard-cli/.adguard_root_helper-real
      ln -s /run/wrappers/bin/adguard_root_helper \
         $out/share/adguard-cli/adguard_root_helper
    fi

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
