-- Nordic keyboard ergonomics + treesitter-textobjects function/class hops.
--
-- Norwegian Mac layout buries `[` and `]` behind Opt+8/Opt+9, so every
-- bracket-prefixed motion in the ecosystem (]f, [c, ]d, ]q, ]b, ...) turns
-- into a two-hand chord. The community-standard fix is to alias the
-- direct keys `æ`/`ø` to `[`/`]` with `remap = true` so downstream
-- bracket motions fire correctly.
--
-- LazyVim's default treesitter-textobjects bindings are mirrored below:
-- `]f`/`[f` function, `]c`/`[c` class, `]a`/`[a` parameter. Paired with
-- the bracket alias you get `øf`/`æf` for next/prev function, etc.
---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    init = function()
      -- Must use remap = true — without it, `ø` sends `]` as a literal key
      -- press that bypasses other mappings, and `øf` falls through to whatever
      -- `]` does on its own (nothing useful) instead of triggering `]f`.
      vim.keymap.set({ "n", "o", "x" }, "ø", "]", { remap = true, desc = "] (bracket forward)" })
      vim.keymap.set({ "n", "o", "x" }, "æ", "[", { remap = true, desc = "[ (bracket back)" })
    end,
    config = function()
      local ok, move = pcall(require, "nvim-treesitter.textobjects.move")
      if not ok then
        return
      end

      local hops = {
        { key = "f", query = "@function.outer", label = "function" },
        { key = "c", query = "@class.outer", label = "class" },
        { key = "a", query = "@parameter.inner", label = "parameter" },
      }

      for _, hop in ipairs(hops) do
        vim.keymap.set({ "n", "x", "o" }, "]" .. hop.key, function()
          move.goto_next_start(hop.query, "textobjects")
        end, { desc = "Next " .. hop.label .. " start" })

        vim.keymap.set({ "n", "x", "o" }, "[" .. hop.key, function()
          move.goto_previous_start(hop.query, "textobjects")
        end, { desc = "Prev " .. hop.label .. " start" })

        vim.keymap.set({ "n", "x", "o" }, "]" .. hop.key:upper(), function()
          move.goto_next_end(hop.query, "textobjects")
        end, { desc = "Next " .. hop.label .. " end" })

        vim.keymap.set({ "n", "x", "o" }, "[" .. hop.key:upper(), function()
          move.goto_previous_end(hop.query, "textobjects")
        end, { desc = "Prev " .. hop.label .. " end" })
      end
    end,
  },
}
