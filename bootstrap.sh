#!/usr/bin/env bash
set -euo pipefail

# ── Bootstrap: fresh macOS → fully configured ────────────────
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles/main/bootstrap.sh | bash
#   — or after cloning —
#   ./bootstrap.sh

REPO="git@github.com:YOU/dotfiles.git"   # ← change this
CONFIG_DIR="$HOME/.config/nixos"
HOSTNAME=$(scutil --get LocalHostName 2>/dev/null || hostname -s)

echo "╔══════════════════════════════════════╗"
echo "║  Axiomatic Systems — machine setup   ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Hostname: $HOSTNAME"
echo "Config:   $CONFIG_DIR"
echo ""

# ── 1. Install Nix (Determinate Systems installer) ───────────
if ! command -v nix &>/dev/null; then
  echo "→ Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install
  # Source nix in current shell
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "→ Nix already installed, skipping."
fi

# ── 2. Install Homebrew (needed for casks) ────────────────────
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "→ Homebrew already installed, skipping."
fi

# ── 3. Clone config repo ─────────────────────────────────────
if [ ! -d "$CONFIG_DIR" ]; then
  echo "→ Cloning config..."
  git clone "$REPO" "$CONFIG_DIR"
else
  echo "→ Config repo exists, pulling latest..."
  git -C "$CONFIG_DIR" pull --ff-only
fi

# ── 4. Build and activate ────────────────────────────────────
echo "→ Building system configuration..."
cd "$CONFIG_DIR"

# First run: nix-darwin isn't in PATH yet, so we use nix run
nix run nix-darwin -- switch --flake ".#${HOSTNAME}"

echo ""
echo "✓ Done. Open a new terminal or run: exec zsh"
echo ""
echo "Future rebuilds:"
echo "  rebuild          # alias defined in shell.nix"
echo "  — or —"
echo "  darwin-rebuild switch --flake ~/.config/nixos"
