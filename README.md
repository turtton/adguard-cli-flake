# adguard-cli-flake

Nix flake for [AdGuard CLI](https://github.com/AdguardTeam/AdGuardCLI) — ad blocking in your terminal.

## Usage

```bash
# Run directly
nix run github:turtton/adguard-cli-flake#adguard-cli -- --help

# Install
nix profile install github:turtton/adguard-cli-flake
```

## Supported platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`

## NixOS

A NixOS module is provided. It installs the package and creates a SUID
wrapper for `adguard_root_helper` (required for automatic proxy mode), which
cannot be SUID inside the read-only Nix store.

```nix
# flake.nix of your system configuration
{
  inputs.adguard-cli-flake.url = "github:turtton/adguard-cli-flake";
}

# configuration.nix (or any module)
{ inputs, ... }: {
  imports = [ inputs.adguard-cli-flake.nixosModules.default ];
  programs.adguard-cli.enable = true;
}
```

Notes on HTTPS filtering:

- `adguard-cli configure` installs the generated CA certificate into Firefox /
  Chrome profiles automatically. The system trust store is skipped because
  NixOS has no writable FHS cert directory; to trust the CA system-wide, add it
  declaratively, e.g. `security.pki.certificateFiles = [ "/home/<you>/.local/share/adguard-cli/AdGuard CLI CA.pem" ];`
- On non-NixOS hosts automatic proxy mode is unavailable for the same SUID
  reason; use manual proxy mode instead.

## License

The flake packaging is MIT. AdGuard CLI itself is GPL-3.0.
