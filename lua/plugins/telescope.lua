-- Telescope: unified fuzzy finder configuration
-- Merges keybindings from the old telescope.lua + mappings.lua

---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {
        pickers = {
          find_files = { hidden = true },
        },
      }
    end,
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fa", function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end, desc = "Find all files (hidden)" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Search text" },
      { "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Symbols in file" },
      { "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Symbols in project" },
      -- fk removed: use <Leader>? for the clean keymap viewer instead
    },
  },
}
