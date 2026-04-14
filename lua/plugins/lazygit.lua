-- Open a terminal with a new group assigned
local function open_grouped_terminal(direction, size)
  local Terminal = require("toggleterm.terminal")
  local all = Terminal.get_all(true)
  local max_id = 0
  for _, t in ipairs(all) do if t.id > max_id then max_id = t.id end end
  local new_id = max_id + 1

  _G._term_groups = _G._term_groups or {}
  _G._term_group_counter = (_G._term_group_counter or 0) + 1
  local gid = _G._term_group_counter
  _G._term_groups[gid] = { new_id }

  local term = Terminal.Terminal:new({ count = new_id, direction = direction })
  term:open(size, direction)
  -- Set group immediately on the new window
  vim.w.term_group = gid
end

return {
  {
    "akinsho/toggleterm.nvim",
    opts = { direction = "float" },
    keys = {
      {
        "<leader>gg",
        function()
          require("toggleterm.terminal").Terminal
            :new({ cmd = "lazygit", hidden = true, direction = "float" })
            :toggle()
        end,
        desc = "LazyGit (float)",
      },
      {
        "<leader>tH",
        function()
          local h = math.max(6, math.floor(vim.api.nvim_win_get_height(0) / 2))
          open_grouped_terminal("horizontal", h)
          vim.cmd("wincmd =")
        end,
        desc = "ToggleTerm horizontal split (center)",
      },
      {
        "<leader>tV",
        function()
          local w = math.max(20, math.floor(vim.api.nvim_win_get_width(0) / 2))
          open_grouped_terminal("vertical", w)
          vim.cmd("wincmd =")
        end,
        desc = "ToggleTerm vertical split (center)",
      },
    },
  },
  -- Override AstroNvim's default <Leader>th/<Leader>tv with group-aware versions
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings or {}
      maps.n = maps.n or {}
      maps.n["<Leader>th"] = {
        function() open_grouped_terminal("horizontal") end,
        desc = "Horizontal terminal",
      }
      maps.n["<Leader>tv"] = {
        function()
          local code_win = vim.api.nvim_get_current_win()
          open_grouped_terminal("vertical")
          -- Code gets 3.5/5 of width, terminal gets 1.5/5
          if vim.api.nvim_win_is_valid(code_win) then
            vim.api.nvim_win_set_width(code_win, math.floor(vim.o.columns * 0.7))
          end
        end,
        desc = "Vertical terminal",
      }
    end,
  },
}
