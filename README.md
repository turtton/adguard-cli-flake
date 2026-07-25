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

## License

The flake packaging is MIT. AdGuard CLI itself is GPL-3.0.
