# copilot-cli-nix

Always up-to-date Nix package for [GitHub Copilot CLI](https://github.com/github/copilot-cli) - AI-powered coding assistant in your terminal.

**Automatically updated hourly** to ensure you always have the latest Copilot CLI version.

**Uses native pre-built binaries** - no Node.js dependency required.

## Why this package?

### Primary Goal: Always Up-to-Date Copilot CLI for Nix Users

This flake provides immediate access to the latest GitHub Copilot CLI versions with:

1. **Native Binary**: Pre-built binary, no runtime dependencies
2. **Hourly Automated Updates**: New versions available within 1 hour of release
3. **Dedicated Maintenance**: Focused repository for quick fixes when Copilot CLI changes
4. **Flake-First Design**: Direct flake usage with Cachix binary cache
5. **Pre-built Binaries**: Multi-platform builds (Linux & macOS) cached for instant installation

### Why Not Just Use the Install Script?

While `curl -fsSL https://gh.io/copilot-install | bash` works, it has limitations:
- **Not Declarative**: Can't be managed in your Nix configuration
- **Not Reproducible**: No version pinning or hash verification
- **Outside Nix**: Doesn't integrate with Nix's dependency management
- **Manual Updates**: Must re-run the script to update

### Comparison Table

| Feature | Install Script | This Flake |
|---------|---------------|------------|
| **Latest Version** | Manual re-run | Hourly checks |
| **Native Binary** | Yes | Yes |
| **Binary Cache** | None | Cachix |
| **Declarative Config** | None | Yes |
| **Version Pinning** | Manual | Flake lock |
| **Reproducible** | No | Yes |
| **CI/CD Ready** | No | Yes |

## Quick Start

### Fastest Installation (Try it now!)

```bash
# Run Copilot CLI directly without installing
nix run github:max-miller1204/copilot-cli-nix
```

### Install to Your System

```bash
# Install native binary
nix profile install github:max-miller1204/copilot-cli-nix
```

### Optional: Enable Binary Cache for Faster Installation

To download pre-built binaries instead of compiling:

```bash
# Install cachix if you haven't already
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Add the copilot-cli-nix cache
cachix use copilot-cli-nix
```

Or add to your Nix configuration:

```nix
{
  nix.settings = {
    substituters = [ "https://copilot-cli-nix.cachix.org" ];
    trusted-public-keys = [ "copilot-cli-nix.cachix.org-1:YOUR_PUBLIC_KEY_HERE" ];
  };
}
```

## Using with Nix Flakes

### In your flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    copilot-cli-nix.url = "github:max-miller1204/copilot-cli-nix";
  };

  outputs = { self, nixpkgs, copilot-cli-nix }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          copilot-cli-nix.packages.${system}.default
        ];
      };
    };
}
```

### Using with NixOS

Add to your system configuration:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.copilot-cli-nix.packages.${pkgs.system}.default
  ];
}
```

### Using with Home Manager

Add to your Home Manager configuration:

```nix
{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.copilot-cli-nix.packages.${pkgs.system}.default
  ];
}
```

## Authentication

GitHub Copilot CLI requires a GitHub account with an active Copilot subscription.

### Interactive Login

```bash
copilot /login
```

### Using a Personal Access Token

Set `GH_TOKEN` or `GITHUB_TOKEN` environment variable with a fine-grained PAT that has the "Copilot Requests" permission:

```bash
export GH_TOKEN="your-token-here"
```

## Technical Details

### Package Architecture

**`copilot` (native binary)**
- Pre-built binary from GitHub's official releases
- Self-contained with minimal runtime dependencies
- On Linux: uses `autoPatchelfHook` for NixOS compatibility (patches ELF interpreter and rpath)
- Supported platforms: `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`

### Features

- **Native Binary**: Self-contained binary with minimal runtime dependencies
- **Version Pinning**: Ensures consistent behavior across different environments
- **Cross-platform Support**: Pre-built binaries for Linux and macOS (x86_64 and ARM64)

## Development

```bash
# Clone the repository
git clone https://github.com/max-miller1204/copilot-cli-nix
cd copilot-cli-nix

# Build locally
nix build

# Test the build
./result/bin/copilot --version

# Enter development shell
nix develop
```

## Updating Copilot CLI Version

### Automated Updates

This repository uses GitHub Actions to automatically check for new Copilot CLI versions hourly. When a new version is detected:

1. A pull request is automatically created with the version update
2. Native binary hashes are automatically calculated for all platforms
3. Tests run on both Linux and macOS to verify the build
4. The PR auto-merges if all checks pass

### Manual Updates

For manual updates:

1. Check for new versions:
   ```bash
   ./scripts/update.sh --check
   ```
2. Update to latest version:
   ```bash
   ./scripts/update.sh
   ```
3. Update to a specific version:
   ```bash
   ./scripts/update.sh --version 1.1.0
   ```
4. Test the build:
   ```bash
   nix build
   ./result/bin/copilot --version
   ```

### Push to Cachix manually
```bash
nix build .#copilot && cachix push copilot-cli-nix ./result
```

## Troubleshooting

### Command not found
Make sure the Nix profile bin directory is in your PATH:
```bash
export PATH="$HOME/.nix-profile/bin:$PATH"
```

### Permission issues on macOS

On macOS, Copilot CLI may ask for permissions after each Nix update because the binary path changes. To fix this:

1. Create a stable symlink:
   ```bash
   mkdir -p ~/.local/bin
   ln -sf $(which copilot) ~/.local/bin/copilot
   ```
2. Add `~/.local/bin` to your PATH
3. Always run `copilot` from `~/.local/bin/copilot`

### unfree license error

GitHub Copilot CLI is proprietary software. If you get an `unfree` error, add to your Nix configuration:

```nix
{ nixpkgs.config.allowUnfree = true; }
```

Or set the environment variable:

```bash
export NIXPKGS_ALLOW_UNFREE=1
```

## Repository Settings

This repository requires specific GitHub settings for automated updates. See [Repository Settings Documentation](.github/REPOSITORY_SETTINGS.md) for configuration details.

## License

This Nix packaging is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

GitHub Copilot CLI itself is proprietary software - see [GitHub's repository](https://github.com/github/copilot-cli) for details.

## Related Projects

- [claude-code-nix](https://github.com/sadjow/claude-code-nix) - Similar packaging for Anthropic's Claude Code
- [codex-cli-nix](https://github.com/sadjow/codex-cli-nix) - Similar packaging for OpenAI's Codex CLI
