#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# setup.sh — Bootstrap a new Ubuntu system with this Neovim/tmux config
# ------------------------------------------------------------------
# Usage: bash setup.sh
#
# Installs:
#   System packages (neovim, tmux, ripgrep, fd-find, fzf, etc.)
#   Language servers & tools (via Mason inside Neovim, but we prepare pip/node)
#   TPM (tmux plugin manager) — run Prefix+I inside tmux to finish
#   Symlinks from ~/Projects/vim/ to ~/.config/nvim/ and ~/.tmux.conf
# ------------------------------------------------------------------

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  neovim \
  tmux \
  ripgrep \
  fd-find \
  fzf \
  git \
  curl \
  wget \
  unzip \
  build-essential \
  cmake \
  python3 \
  python3-pip \
  python3-venv \
  nodejs \
  npm \
  pkg-config \
  libssl-dev

echo "==> Installing pynvim (Python neovim client)..."
pip3 install --user --break-system-packages --quiet pynvim

echo "==> Configuring symlinks..."
# Neovim config
mkdir -p ~/.config/nvim
ln -sf "$REPO_DIR/init.lua" ~/.config/nvim/init.lua

# Tmux config
ln -sf "$REPO_DIR/.tmux.conf" ~/.tmux.conf

echo "==> Installing TPM (tmux plugin manager)..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "==> Installing tmux plugins (headless)..."
~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true

echo ""
echo "============================================"
echo "  Setup complete!"
echo ""
echo "  Next steps:"
echo "    1. Open tmux  ->  press Prefix+I  to install plugins"
echo "    2. Open nvim  ->  Mason will auto-install LSP servers"
echo "    3. Install a Nerd Font (optional but recommended)"
echo "       e.g. JetBrainsMono Nerd Font:"
echo "       https://www.nerdfonts.com/font-downloads"
echo "============================================"
