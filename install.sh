#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dahl-jar/nvim-config.git"
NVIM_DIR="$HOME/.config/nvim"

msg() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      [ -r /etc/os-release ] || { echo linux; return; }
      # shellcheck disable=SC1091
      . /etc/os-release
      echo "${ID:-linux}"
      ;;
    *) echo unknown ;;
  esac
}

install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    msg "installing Homebrew (this pulls Apple Command Line Tools automatically)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  msg "installing packages via brew"
  brew install neovim git ripgrep fd lazygit node uv openjdk
  brew install --cask font-jetbrains-mono-nerd-font || msg "nerd font cask skipped (already installed or unavailable)"
}

install_debian() {
  msg "installing packages via apt"
  sudo apt-get update
  sudo apt-get install -y \
    git curl tar gzip unzip fontconfig build-essential \
    ripgrep nodejs npm default-jdk
  sudo apt-get install -y fd-find || true
  sudo apt-get install -y lazygit || msg "lazygit not in apt (skip — install via go or binary if you want it)"
  install_neovim_tarball
  ensure_fd_symlink
  ensure_uv
  install_nerd_font_linux
}

install_arch() {
  msg "installing packages via pacman"
  sudo pacman -Sy --needed --noconfirm \
    neovim git curl tar unzip fontconfig base-devel \
    ripgrep fd lazygit nodejs npm jdk-openjdk ttf-jetbrains-mono-nerd
  ensure_uv
}

install_fedora() {
  msg "installing packages via dnf"
  sudo dnf install -y \
    neovim git curl tar unzip fontconfig \
    ripgrep fd-find lazygit nodejs \
    java-latest-openjdk-devel \
    @development-tools
  ensure_uv
  install_nerd_font_linux
}

install_neovim_tarball() {
  if command -v nvim >/dev/null 2>&1; then
    local minor
    minor=$(nvim --version | head -1 | sed -E 's/^NVIM v[0-9]+\.([0-9]+).*/\1/')
    if [ "${minor:-0}" -ge 10 ]; then
      msg "neovim already >= 0.10, keeping it"
      return
    fi
  fi
  msg "installing Neovim from official tarball"
  local tmp
  tmp=$(mktemp -d)
  curl -fLo "$tmp/nvim.tar.gz" \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
  sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
}

ensure_fd_symlink() {
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

ensure_uv() {
  if ! command -v uv >/dev/null 2>&1; then
    msg "installing uv (Python package/venv manager)"
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
}

install_nerd_font_linux() {
  if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd'; then
    msg "JetBrainsMono Nerd Font already installed"
    return
  fi
  msg "installing JetBrainsMono Nerd Font"
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  local tmp
  tmp=$(mktemp)
  mkdir -p "$font_dir"
  curl -fLo "$tmp" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -oq "$tmp" -d "$font_dir"
  fc-cache -f "$font_dir"
  rm -f "$tmp"
}

backup_existing_nvim() {
  local ts
  ts=$(date +%Y%m%d-%H%M%S)
  for d in "$NVIM_DIR" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    [ -e "$d" ] || continue
    msg "backing up $d -> $d.bak-$ts"
    mv "$d" "$d.bak-$ts"
  done
}

clone_config() {
  msg "cloning $REPO_URL -> $NVIM_DIR"
  mkdir -p "$(dirname "$NVIM_DIR")"
  git clone "$REPO_URL" "$NVIM_DIR"
}

main() {
  local os
  os=$(detect_os)
  msg "detected OS: $os"
  case "$os" in
    macos) install_macos ;;
    ubuntu|debian|pop|linuxmint|raspbian) install_debian ;;
    arch|manjaro|endeavouros|cachyos) install_arch ;;
    fedora|rhel|rocky|almalinux) install_fedora ;;
    *) die "unsupported distro: $os — install deps manually, then clone $REPO_URL into $NVIM_DIR" ;;
  esac
  backup_existing_nvim
  clone_config
  echo
  msg "done"
  echo
  echo "Next steps:"
  echo "  1. Run: nvim                    (plugins + Mason bootstrap on first launch)"
  echo "  2. In nvim: :Codeium Auth       (one-time AI completion setup)"
}

main "$@"
