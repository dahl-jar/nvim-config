-- Customize Treesitter - syntax highlighting, indentation, and code parsing

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    if opts.ensure_installed == "all" then return end
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "tsx",
      "jsdoc",
      "json",
      "jsonc",
      "html",
      "css",
      "scss",
      "styled",
      "python",
      "java",
      "bash",
      "markdown",
      "markdown_inline",
      "yaml",
      "toml",
      "regex",
      "gitcommit",
      "diff",
    })
  end,
}
