-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    -- Diagnostics configuration
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        tabstop = 2,
        shiftwidth = 2,
        expandtab = true,
        scrolloff = 8,
        sidescrolloff = 8,
        cursorline = true,
        termguicolors = true,
        clipboard = "unnamedplus",
        -- Lower timeout so which-key shows up faster (300ms instead of 1000ms)
        timeoutlen = 300,
        belloff = "all", -- disable terminal bell
      },
      g = {},
    },
    -- Terminal tab groups: each window owns its own independent set of tabs
    -- _G._term_groups[group_id] = { term_id1, term_id2, ... }
    -- vim.w.term_group = group_id (window-local)
    autocmds = {
      terminal_tabbar = {
        {
          event = { "TermOpen", "BufEnter", "TermClose" },
          pattern = "term://*toggleterm#*",
          callback = function(args)
            local win = vim.api.nvim_get_current_win()
            local buf = args.buf
            vim.schedule(function()
              local ok, _ = pcall(require, "toggleterm.terminal")
              if not ok then return end
              if not vim.api.nvim_win_is_valid(win) then return end
              if not vim.api.nvim_buf_is_valid(buf) then return end

              local current = vim.b[buf].toggle_number
              if not current then return end

              -- Auto-assign a group if this terminal window doesn't have one
              _G._term_groups = _G._term_groups or {}
              _G._term_group_counter = _G._term_group_counter or 0
              local group_id
              local ok2, gid = pcall(vim.api.nvim_win_get_var, win, "term_group")
              if ok2 and gid then
                group_id = gid
              else
                _G._term_group_counter = _G._term_group_counter + 1
                group_id = _G._term_group_counter
                vim.api.nvim_win_set_var(win, "term_group", group_id)
                _G._term_groups[group_id] = { current }
              end
              -- Ensure current terminal is in its group
              local found = false
              for _, id in ipairs(_G._term_groups[group_id] or {}) do
                if id == current then found = true break end
              end
              if not found then
                _G._term_groups[group_id] = _G._term_groups[group_id] or {}
                table.insert(_G._term_groups[group_id], current)
              end

              local group = _G._term_groups[group_id] or {}

              -- Build winbar from group terminals only
              local parts = {}
              for i, tid in ipairs(group) do
                local click = "%" .. tid .. "@v:lua._term_switch@"
                if tid == current then
                  table.insert(parts, click .. "%#TabLineSel#  " .. i .. " %X%#TabLine#")
                else
                  table.insert(parts, click .. "%#TabLine#  " .. i .. " %X")
                end
              end

              if vim.api.nvim_win_is_valid(win) then
                vim.wo[win].winbar = table.concat(parts)
                  .. "%#TabLineFill#%="
                  .. "%@v:lua._term_new@%#TabLine#  + %X"
                  .. "%@v:lua._term_close@%#TabLine#  x %X"
              end
            end)
          end,
        },
      },
      -- Define click handlers ONCE — use buffer swapping, no close/open
      terminal_handlers_init = {
        {
          event = "VimEnter",
          callback = function()
            local function find_term(id)
              for _, t in ipairs(require("toggleterm.terminal").get_all(true)) do
                if t.id == id then return t end
              end
            end

            local function get_context()
              local cur_id = vim.b.toggle_number
              if not cur_id then return nil end
              local ok, gid = pcall(vim.api.nvim_win_get_var, 0, "term_group")
              if not ok or not gid then return nil end
              local dir = "horizontal"
              for _, t in ipairs(require("toggleterm.terminal").get_all(true)) do
                if t.id == cur_id then dir = t.direction break end
              end
              return { id = cur_id, group_id = gid, dir = dir }
            end

            -- Switch tab: swap buffer in current window (no close/open)
            _G._term_switch = function(minwid)
              local ctx = get_context()
              if not ctx or minwid == ctx.id then return end
              local target = find_term(minwid)
              if target and target.bufnr and vim.api.nvim_buf_is_valid(target.bufnr) then
                vim.api.nvim_win_set_buf(0, target.bufnr)
              end
            end

            -- New tab: create terminal, swap its buffer into current window
            _G._term_new = function()
              local ctx = get_context()
              if not ctx then return end
              local my_win = vim.api.nvim_get_current_win()
              local Terminal = require("toggleterm.terminal")
              local all = Terminal.get_all(true)
              local max_id = 0
              for _, t in ipairs(all) do
                if t.id > max_id then max_id = t.id end
              end
              local new_id = max_id + 1
              local new_term = Terminal.Terminal:new({ count = new_id, direction = ctx.dir })
              -- Add to group
              local g = _G._term_groups[ctx.group_id] or {}
              table.insert(g, new_id)
              _G._term_groups[ctx.group_id] = g
              -- Open in a temporary split, grab buffer, close the split
              new_term:open(nil, ctx.dir)
              local new_buf = new_term.bufnr
              local new_win = vim.api.nvim_get_current_win()
              if new_win ~= my_win and new_buf and vim.api.nvim_buf_is_valid(new_buf) then
                -- Close the extra split and show buffer in original window
                pcall(vim.api.nvim_win_close, new_win, true)
                vim.api.nvim_set_current_win(my_win)
                vim.api.nvim_win_set_buf(my_win, new_buf)
              end
              vim.w.term_group = ctx.group_id
            end

            -- Close tab: swap to next tab FIRST, then destroy old terminal
            _G._term_close = function()
              local ctx = get_context()
              if not ctx then return end
              local g = _G._term_groups[ctx.group_id] or {}
              local idx
              for i, id in ipairs(g) do
                if id == ctx.id then idx = i break end
              end
              if not idx then return end
              local next_id = g[idx + 1] or g[idx - 1]
              table.remove(g, idx)
              _G._term_groups[ctx.group_id] = g

              if next_id then
                -- Swap to next tab's buffer BEFORE destroying current
                local next_term = find_term(next_id)
                if next_term and next_term.bufnr and vim.api.nvim_buf_is_valid(next_term.bufnr) then
                  vim.api.nvim_win_set_buf(0, next_term.bufnr)
                  vim.w.term_group = ctx.group_id
                end
              end

              -- Now safely destroy the old terminal (window won't close)
              local cur = find_term(ctx.id)
              if cur then cur:shutdown() end
            end
          end,
        },
      },
      -- Auto-enter terminal mode when focusing a terminal
      terminal_auto_insert = {
        {
          event = "TermOpen",
          callback = function()
            vim.wo.wrap = true
            vim.wo.sidescrolloff = 0
            vim.cmd("startinsert")
          end,
        },
        {
          event = "WinEnter",
          callback = function()
            if vim.bo.buftype == "terminal" then
              vim.defer_fn(function()
                if vim.bo.buftype == "terminal" and vim.api.nvim_get_mode().mode ~= "t" then
                  vim.cmd("startinsert")
                end
              end, 10)
            end
          end,
        },
      },
    },
    -- Mappings
    mappings = {
      -- Norwegian keyboard: Option+key sends <M-composed_char> in Neovim.
      -- Without these, <M-[> is interpreted as <Esc>[ which exits insert mode.
      i = {
        ["<M-[>"] = { "[" }, ["<M-]>"] = { "]" },
        ["<M-{>"] = { "{" }, ["<M-}>"] = { "}" },
        ["<M-|>"] = { "|" }, ["<M-\\>"] = { "\\" },
      },
      c = {
        ["<M-[>"] = { "[" }, ["<M-]>"] = { "]" },
        ["<M-{>"] = { "{" }, ["<M-}>"] = { "}" },
        ["<M-|>"] = { "|" }, ["<M-\\>"] = { "\\" },
      },
      -- Terminal mode: Ctrl+\ exits to normal mode (for scrolling)
      t = {
        ["<C-\\>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
        -- Keep Leader accessible from terminal mode
        ["<C-Space>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
      },
      n = {
        -- Buffer navigation
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Show all keybindings in a clean, searchable Telescope picker
        ["<Leader>?"] = {
          function()
            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local conf = require("telescope.config").values
            local entry_display = require("telescope.pickers.entry_display")

            local mode_names = {
              n = "Normal", i = "Insert", v = "Visual",
              x = "Visual Block", t = "Terminal",
            }
            local leader = vim.g.mapleader or "\\"

            local keymaps = {}
            local seen = {}
            for mode, name in pairs(mode_names) do
              -- Merge global + buffer-local keymaps
              local maps = vim.api.nvim_get_keymap(mode)
              for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
                table.insert(maps, m)
              end
              for _, map in ipairs(maps) do
                if map.desc and map.desc ~= "" and not map.lhs:match("<Plug>") then
                  local key = mode .. map.lhs
                  if not seen[key] then
                    seen[key] = true
                    -- Replace leader character with <Leader> for display
                    local lhs = map.lhs
                    if leader == " " and lhs:sub(1, 1) == " " then
                      lhs = "<Leader>" .. lhs:sub(2)
                    elseif lhs:sub(1, #leader) == leader then
                      lhs = "<Leader>" .. lhs:sub(#leader + 1)
                    end
                    table.insert(keymaps, { lhs = lhs, desc = map.desc, mode = name })
                  end
                end
              end
            end

            -- Sort: leader keymaps first, then alphabetically
            table.sort(keymaps, function(a, b)
              local a_leader = a.lhs:match("^<Leader>") and 0 or 1
              local b_leader = b.lhs:match("^<Leader>") and 0 or 1
              if a_leader ~= b_leader then return a_leader < b_leader end
              return a.lhs < b.lhs
            end)

            local displayer = entry_display.create {
              separator = "  ",
              items = {
                { width = 20 },
                { width = 12 },
                { remaining = true },
              },
            }

            pickers.new({}, {
              wrap_results = true,
              prompt_title = "Keybindings",
              finder = finders.new_table {
                results = keymaps,
                entry_maker = function(entry)
                  return {
                    value = entry,
                    display = function(e)
                      return displayer {
                        { e.value.lhs, "TelescopeResultsIdentifier" },
                        { e.value.mode, "TelescopeResultsComment" },
                        { e.value.desc },
                      }
                    end,
                    ordinal = entry.lhs .. " " .. entry.mode .. " " .. entry.desc,
                  }
                end,
              },
              sorter = conf.generic_sorter {},
            }):find()
          end,
          desc = "Search all keybindings",
        },

        -- Dual horizontal terminal split (each gets its own group)
        ["<Leader>t2"] = {
          function()
            local Terminal = require("toggleterm.terminal")
            local all = Terminal.get_all(true)
            local max_id = 0
            for _, t in ipairs(all) do if t.id > max_id then max_id = t.id end end
            _G._term_groups = _G._term_groups or {}
            _G._term_group_counter = (_G._term_group_counter or 0) + 1
            local gid1 = _G._term_group_counter
            _G._term_group_counter = _G._term_group_counter + 1
            local gid2 = _G._term_group_counter
            local id1, id2 = max_id + 1, max_id + 2
            _G._term_groups[gid1] = { id1 }
            _G._term_groups[gid2] = { id2 }
            local t1 = Terminal.Terminal:new({ direction = "horizontal", count = id1 })
            local t2 = Terminal.Terminal:new({ direction = "horizontal", count = id2 })
            -- Open t1, tag its window immediately
            t1:toggle()
            vim.w.term_group = gid1
            -- Open t2, tag its window immediately
            t2:toggle()
            vim.w.term_group = gid2
            vim.cmd("wincmd =")
          end,
          desc = "Two horizontal terminals",
        },

        -- Dual vertical terminal split (each gets its own group)
        ["<Leader>t3"] = {
          function()
            local code_win = vim.api.nvim_get_current_win()
            local Terminal = require("toggleterm.terminal")
            local all = Terminal.get_all(true)
            local max_id = 0
            for _, t in ipairs(all) do if t.id > max_id then max_id = t.id end end
            _G._term_groups = _G._term_groups or {}
            _G._term_group_counter = (_G._term_group_counter or 0) + 1
            local gid1 = _G._term_group_counter
            _G._term_group_counter = _G._term_group_counter + 1
            local gid2 = _G._term_group_counter
            local id1, id2 = max_id + 1, max_id + 2
            _G._term_groups[gid1] = { id1 }
            _G._term_groups[gid2] = { id2 }
            local t1 = Terminal.Terminal:new({ direction = "vertical", count = id1 })
            local t2 = Terminal.Terminal:new({ direction = "vertical", count = id2 })
            t1:toggle()
            vim.w.term_group = gid1
            t2:toggle()
            vim.w.term_group = gid2
            vim.cmd("wincmd =")
            -- Code gets 3.5/5 of width, terminals share 1.5/5
            if vim.api.nvim_win_is_valid(code_win) then
              vim.api.nvim_win_set_width(code_win, math.floor(vim.o.columns * 0.7))
            end
          end,
          desc = "Two vertical terminals",
        },

        -- Terminal tab navigation (group-aware)
        ["<Leader>tn"] = {
          function()
            local group_id = vim.w.term_group
            if not group_id then return end
            _G._term_groups = _G._term_groups or {}
            local group = _G._term_groups[group_id] or {}
            local Terminal = require("toggleterm.terminal")
            local all = Terminal.get_all(true)
            local cur_id = vim.b.toggle_number
            local dir = "horizontal"
            for _, t in ipairs(all) do
              if t.id == cur_id then dir = t.direction; t:close() break end
            end
            local max_id = 0
            for _, t in ipairs(all) do if t.id > max_id then max_id = t.id end end
            local new_id = max_id + 1
            table.insert(group, new_id)
            _G._term_groups[group_id] = group
            local new_term = Terminal.Terminal:new({ count = new_id, direction = dir })
            new_term:open(nil, dir)
          end,
          desc = "New terminal tab",
        },
        ["<Leader>t]"] = {
          function()
            local group_id = vim.w.term_group
            if not group_id then return end
            local group = (_G._term_groups or {})[group_id] or {}
            if #group < 2 then return end
            local cur_id = vim.b.toggle_number
            local Terminal = require("toggleterm.terminal")
            local dir = "horizontal"
            for _, t in ipairs(Terminal.get_all(true)) do
              if t.id == cur_id then dir = t.direction break end
            end
            -- Find current index in group and go to next
            for i, id in ipairs(group) do
              if id == cur_id then
                local next_id = group[i % #group + 1]
                local cur = nil
                for _, t in ipairs(Terminal.get_all(true)) do
                  if t.id == cur_id then cur = t break end
                end
                if cur then cur:close() end
                local next_term = nil
                for _, t in ipairs(Terminal.get_all(true)) do
                  if t.id == next_id then next_term = t break end
                end
                if next_term then
                  next_term.direction = dir
                  next_term:open(nil, dir)
                end
                break
              end
            end
          end,
          desc = "Next terminal tab",
        },
        ["<Leader>t["] = {
          function()
            local group_id = vim.w.term_group
            if not group_id then return end
            local group = (_G._term_groups or {})[group_id] or {}
            if #group < 2 then return end
            local cur_id = vim.b.toggle_number
            local Terminal = require("toggleterm.terminal")
            local dir = "horizontal"
            for _, t in ipairs(Terminal.get_all(true)) do
              if t.id == cur_id then dir = t.direction break end
            end
            for i, id in ipairs(group) do
              if id == cur_id then
                local prev_id = group[(i - 2) % #group + 1]
                local cur = nil
                for _, t in ipairs(Terminal.get_all(true)) do
                  if t.id == cur_id then cur = t break end
                end
                if cur then cur:close() end
                local prev_term = nil
                for _, t in ipairs(Terminal.get_all(true)) do
                  if t.id == prev_id then prev_term = t break end
                end
                if prev_term then
                  prev_term.direction = dir
                  prev_term:open(nil, dir)
                end
                break
              end
            end
          end,
          desc = "Previous terminal tab",
        },
        ["<Leader>ts"] = { "<cmd>TermSelect<CR>", desc = "Select terminal" },
        ["<Leader>tx"] = {
          function()
            local group_id = vim.w.term_group
            if not group_id then return end
            local group = (_G._term_groups or {})[group_id] or {}
            local cur_id = vim.b.toggle_number
            if not cur_id then return end
            local Terminal = require("toggleterm.terminal")
            local dir = "horizontal"
            for _, t in ipairs(Terminal.get_all(true)) do
              if t.id == cur_id then dir = t.direction break end
            end
            -- Find and remove from group
            local idx
            for i, id in ipairs(group) do
              if id == cur_id then idx = i break end
            end
            if not idx then return end
            local next_id = group[idx + 1] or group[idx - 1]
            table.remove(group, idx)
            _G._term_groups[group_id] = group
            local cur = nil
            for _, t in ipairs(Terminal.get_all(true)) do
              if t.id == cur_id then cur = t break end
            end
            if cur then cur:shutdown() end
            if next_id then
              vim.schedule(function()
                local next_term = nil
                for _, t in ipairs(Terminal.get_all(true)) do
                  if t.id == next_id then next_term = t break end
                end
                if next_term then
                  next_term.direction = dir
                  next_term:open(nil, dir)
                  if next_term.window then
                    vim.api.nvim_set_current_win(next_term.window)
                  end
                end
              end)
            end
          end,
          desc = "Close current terminal",
        },

        -- Code splits
        ["<Leader>s"] = { desc = "Split" },
        ["<Leader>sh"] = { "<cmd>split<CR>", desc = "Horizontal split" },
        ["<Leader>sv"] = { "<cmd>vsplit<CR>", desc = "Vertical split" },

        -- Toggle Codeium suggestions
        ["<Leader>uc"] = {
          function()
            if vim.g.codeium_enabled == 0 then
              vim.g.codeium_enabled = 1
              vim.notify("Codeium enabled", vim.log.levels.INFO)
            else
              vim.g.codeium_enabled = 0
              vim.notify("Codeium disabled", vim.log.levels.INFO)
            end
          end,
          desc = "Toggle Codeium",
        },

        -- Which-key group names
        ["<Leader>b"] = { desc = "Buffers" },
        ["<Leader>f"] = { desc = "Find" },
        ["<Leader>g"] = { desc = "Git" },
        ["<Leader>u"] = { desc = "UI/Toggle" },
        ["<Leader>l"] = { desc = "LSP" },
        ["<Leader>d"] = { desc = "Debug" },
      },
    },
  },
}
