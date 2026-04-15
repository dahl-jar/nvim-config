-- Smooth scroll animation for built-in scrolling commands: Ctrl-u, Ctrl-d,
-- Ctrl-f, Ctrl-b, zz, zt, zb. No custom motion keys — that's flash.nvim's
-- and treesitter-textobjects' job.
---@type LazySpec
return {
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      easing = "sine",
      hide_cursor = false,
      stop_eof = true,
      respect_scrolloff = true,
      cursor_scrolls_alone = false,
    },
  },
}
