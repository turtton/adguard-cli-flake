# adguard-cli-flake — AGENTS.md

Nix flake for [AdGuard CLI](https://github.com/AdguardTeam/AdGuardCLI). Downloads prebuilt tarballs from GitHub releases.

## Repo structure

| File | Purpose |
|---|---|
| `flake.nix` | Flake entrypoint — calls `package.nix` per system; provides `nixosModules.adguard-cli` |
| `package.nix` | Derivation — fetches tarball from URL in `hashes.json`, extracts and installs |
| `patches/install_cert-nixos.patch` | Don't abort `install_cert.sh` when no FHS system cert dir exists (NixOS); skip system store, still configure browsers |
| `hashes.json` | Version + per-system URL+SRI-hash map |
| `update.sh` | Fetches latest release from GitHub API, re-hashes, writes `hashes.json` |
| `.github/workflows/ci.yml` | PR/push CI: `nix build .#adguard-cli` — triggered on `pull_request` and `push` to `main` |
| `.github/workflows/update.yml` | Daily cron: `update.sh` → build → PR |

## Key commands

```bash
# Build locally
nix build .#adguard-cli

# Run the built binary
./result/bin/adguard-cli --version

# Update to latest upstream release
bash update.sh
nix build .#adguard-cli
```

`update.sh --force` re-fetches hashes even if the version hasn't changed.

## Supported systems

`x86_64-linux`, `aarch64-linux`, `x86_64-darwin`.

Note: AArch64 Darwin (`aarch64-darwin`) is not available from upstream — only `macos` (x86_64) tarball is published.

## Packaging details

- **Tarball structure**: `adguard-cli-{version}-{platform}/` containing `adguard-cli` binary, helper tools, and shell completion
- **Main binary**: installed to `$out/bin/adguard-cli` (symlink to `$out/share/adguard-cli/adguard-cli`)
- **Helper tools**: `adguard_cli_nm`, `adguard_root_helper`, `certutil` installed in `$out/share/adguard-cli/`
- **bash completion**: installed to `$out/share/bash-completion/completions/`

## Tag format

AdGuard CLI uses a non-standard tag format: `v{version}-release` (e.g., `v1.4.13-release`).
`update.sh` handles this by stripping both the `v` prefix and the `-release` suffix.

## Updating

The auto-update workflow (`.github/workflows/update.yml`) runs daily at 06:00 UTC and can be triggered manually via workflow_dispatch. It runs `update.sh`, builds the derivation, and opens a PR on `auto-update` branch.

## CI

`.github/workflows/ci.yml` runs `nix build .#adguard-cli` on every PR targeting `main` and every push to `main`.

## Auto-update PR and CI

For CI to run automatically on auto-update PRs, a **GitHub Personal Access Token (PAT)** must be configured:

1. Create a fine-grained PAT at https://github.com/settings/tokens with:
   - Repository access: `turtton/adguard-cli-flake` only
   - Permissions: **Contents** (Read and write), **Pull requests** (Read and write)
2. Add it as a repository secret:
   ```bash
   gh secret set PAT_TOKEN
   ```

Without `PAT_TOKEN`, the workflow falls back to `GITHUB_TOKEN`. PRs are still created, but CI runs must be approved manually.

## Mergify

`.mergify.yml` auto-merges PRs from the `auto-update` branch when CI passes. Only PRs created by `turtton` are auto-merged.
