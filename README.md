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

## Structure

This flake follows the [prebuilt-binary template](https://github.com/turtton/flake-templates#prebuilt-binary) with:

- Automated daily version checks via GitHub Actions (06:00 UTC)
- Auto-merge PRs via Mergify when version bumps pass CI
- PAT_TOKEN support for CI auto-trigger on auto-update PRs

## Setup

After cloning, run `bash update.sh` to fetch the latest version hashes, then `nix build .#adguard-cli` to verify.

### PAT_TOKEN (optional)

For CI to auto-trigger on `auto-update` PRs, set the `PAT_TOKEN` repository secret.

## License

The flake packaging is MIT. AdGuard CLI itself is GPL-3.0.
