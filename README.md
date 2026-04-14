# nvim-config

Personal [AstroNvim](https://github.com/AstroNvim/AstroNvim) v5+ setup.

## Install

One command on a fresh machine (macOS, Debian/Ubuntu, Arch, or Fedora):

```shell
bash <(curl -fsSL https://raw.githubusercontent.com/dahl-jar/nvim-config/main/install.sh)
```

It installs Neovim >= 0.10, a C toolchain, Node.js, Java, uv, ripgrep, fd,
lazygit, and a JetBrainsMono Nerd Font via the platform's package manager
(Homebrew / apt / pacman / dnf), backs up any existing nvim state, then clones
this repo to `~/.config/nvim`.

Then:

```shell
nvim                 # first launch bootstraps plugins + Mason
:Codeium Auth        # one-time AI completion setup (inside nvim)
```

## Manual install

If you don't want the script, install the dependencies yourself and clone:

```shell
git clone https://github.com/dahl-jar/nvim-config.git ~/.config/nvim
```
