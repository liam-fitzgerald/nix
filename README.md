# dotfiles

Declarative macOS and Linux user environment via [nix-darwin](https://github.com/LnL7/nix-darwin), [NixOS](https://nixos.org/), and [home-manager](https://github.com/nix-community/home-manager).

## Fresh machine setup

```bash
# Option A: one-liner (after uploading bootstrap.sh to your repo)
curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles/main/bootstrap.sh | bash

# Option B: manual
curl -L https://install.determinate.systems/nix | sh
git clone git@github.com:YOU/dotfiles.git ~/.config/nixos
cd ~/.config/nixos && nix run nix-darwin -- switch --flake ".#$(scutil --get LocalHostName)"
```

## Daily usage

```bash
rebuild                    # alias picks darwin-rebuild, nixos-rebuild, or home-manager
```

Edit any `.nix` file, run `rebuild`, done.

## Linux / NixOS

Standalone Home Manager on Linux:

```bash
home-manager switch --flake ~/.config/nix#test@x86_64-linux
```

NixOS:

```bash
sudo nixos-rebuild switch --flake ~/.config/nix#linux
```

The built-in `linux` NixOS target includes generic EFI/root filesystem defaults in `hosts/nixos.nix`. On a real machine, override those with your machine's hardware configuration if it differs from `/dev/disk/by-label/NIXOS`.

## Structure

```
flake.nix              # inputs + wiring
hosts/darwin.nix       # system-level: macOS defaults, brew casks, networking
hosts/linux.nix        # reusable NixOS workstation module
hosts/nixos.nix        # generic NixOS host wrapper
home/
  default.nix          # user packages
  shell.nix            # zsh, starship, tmux
  git.nix              # git, delta, gh
  dev.nix              # sbcl, rust, emacs, dev tools
bootstrap.sh           # fresh machine setup script
```

## Adding packages

**CLI tool from nixpkgs:** add to `home.packages` in the relevant `home/*.nix` file.

**GUI app (macOS):** add to `homebrew.casks` in `hosts/darwin.nix`.

**Per-project tools:** use a `flake.nix` in the project dir + direnv:

```nix
# project/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [ pkgs.sbcl pkgs.lmdb ];
    };
  };
}
```

```bash
# project/.envrc
use flake
```

Then `direnv allow` and you get project-specific deps without polluting global env.
