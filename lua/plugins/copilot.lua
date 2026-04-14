return {
  -- Disable Copilot and Supermaven
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },
  { "supermaven-inc/supermaven-nvim", enabled = false },

  -- Codeium: free AI inline completion
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    cmd = { "Codeium", "CodeiumAuth" },
    init = function()
      vim.g.codeium_enabled = true
      vim.g.codeium_disable_bindings = 1
    end,
    config = function()
      -- Keybindings matching what you had before
      vim.keymap.set("i", "<C-CR>", function() return vim.fn["codeium#Accept"]() end, { expr = true, silent = true, desc = "Accept suggestion (Codeium)" })
      vim.keymap.set("i", "<S-Tab>", function() return vim.fn["codeium#AcceptNextWord"]() end, { expr = true, silent = true, desc = "Accept word (Codeium)" })
      vim.keymap.set("i", "<C-]>", function() return vim.fn["codeium#Clear"]() end, { expr = true, silent = true, desc = "Clear suggestion (Codeium)" })
      vim.keymap.set("i", "<C-n>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true, silent = true, desc = "Next suggestion (Codeium)" })
      vim.keymap.set("i", "<C-p>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true, silent = true, desc = "Prev suggestion (Codeium)" })
    end,
  },
}
