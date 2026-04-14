# nvim-config

Personal [AstroNvim](https://github.com/AstroNvim/AstroNvim) v5+ setup.

## Install

```shell
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null

git clone https://github.com/dahl-jar/nvim-config.git ~/.config/nvim
nvim
```

First launch installs plugins from `lazy-lock.json` and Mason tooling. Requires
Neovim >= 0.10, git, a Nerd Font, and ripgrep.
