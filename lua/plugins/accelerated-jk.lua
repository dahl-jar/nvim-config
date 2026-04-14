return {
  -- Accelerated movement setup
  {
    "rainbowhxch/accelerated-jk.nvim",
    config = function()
      require("accelerated-jk").setup({
        mode = "time_driven",
        enable_deceleration = true,
        acceleration_motions = { "j", "k", "Left", "Right" },
        acceleration_limit = 150,
      })

      -- Put inside your existing config() block
      local FAST_STEP = 5

      -- Fast vertical (Insert mode)
      vim.keymap.set("i", "<S-Up>", function() return ("<C-o>%dk"):format(FAST_STEP) end,
        { expr = true, silent = true, desc = "Insert: fast up" })
      vim.keymap.set("i", "<S-Down>", function() return ("<C-o>%dj"):format(FAST_STEP) end,
        { expr = true, silent = true, desc = "Insert: fast down" })

      -- Word-wise left/right in Insert mode (no terminal hacks needed)
      vim.keymap.set("i", "<S-Left>",  "<C-o>b", { silent = true, desc = "Insert: left by word" })
      vim.keymap.set("i", "<S-Right>", "<C-o>w", { silent = true, desc = "Insert: right by word" })
      -- (Optional) Also speed up Shift+Left/Right by WORDS in insert mode
      vim.keymap.set("i", "<S-Left>", "<C-o>b", { silent = true, desc = "Insert: back a word" })
      vim.keymap.set("i", "<S-Right>", "<C-o>w", { silent = true, desc = "Insert: forward a word" })
            -- Accelerated movement mappings
      vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)", {})
      vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)", {})
      vim.keymap.set("n", "<Left>", "<Plug>(accelerated_jk_h)", {})
      vim.keymap.set("n", "<Right>", "<Plug>(accelerated_jk_l)", {})

      -- Faster delete using counts
      vim.keymap.set("n", "<Del>", function()
        return tostring(vim.v.count1) .. "x"
      end, { expr = true, silent = true, desc = "Accelerated delete (count-aware)" })

      -- Undo / Redo (since <leader>u is used for UI)
      vim.keymap.set("n", "<C-z>", "u", { desc = "Undo" })
      vim.keymap.set("n", "<S-C-z>", "<C-r>", { desc = "Redo" })
      vim.keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo (Alt key)" })

      -- Go to TOP / BOTTOM instantly (centered)
      vim.keymap.set("n", "<leader>t", "ggzz", { desc = "Go to top of file" })
      vim.keymap.set("n", "<leader>b", "Gzz",  { desc = "Go to bottom of file" })

      -- Select ALL from anywhere (no need to be at top)
      vim.keymap.set({ "n", "v" }, "<leader>a", "ggVG", { desc = "Select entire buffer" })
    end,
  },

  -- Optional: visual undo tree browser
  {
    "mbbill/undotree",
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undo Tree" },
    },
  },
}
