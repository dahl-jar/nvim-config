-- flash.nvim: label-based jumps anywhere visible on screen.
--
-- Usage:
--   s{char}{char} -> labels appear on every match; press label -> jump
--   S             -> treesitter mode, labels on every AST node
--   r (op-pend)   -> remote operations (dR{label} deletes that thing)
--   R (visual)    -> treesitter search, pick any node
--
-- This replaces hold-to-repeat paragraph hopping — flash is faster once
-- you have the muscle memory: two chars + a label gets you anywhere.
---@type LazySpec
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = true },
        char = { enabled = true, jump_labels = true },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
    },
  },
}
