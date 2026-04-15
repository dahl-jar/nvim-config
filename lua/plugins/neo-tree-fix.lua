-- Side-steps E94 on paths with `[...]` (e.g. Next.js dynamic routes) by
-- disabling neo-tree's `close_if_last_window`. AstroNvim turns that on by
-- default, which routes us into a handler that runs `vim.cmd("b " .. buf_name)`
-- — the `:b` ex-command treats its argument as a regex, so bracketed paths
-- trigger E94. Disabling the feature bypasses the buggy code path entirely.
-- We lose "auto-close neo-tree when it's the last window", which in practice
-- means you close it manually with <Leader>e.
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.close_if_last_window = false
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.use_libuv_file_watcher = true
      -- Avoid resolving terminal buffer names (term://...) as filesystem paths.
      opts.filesystem.follow_current_file = { enabled = false }

      -- Re-open explorer after file is opened (prevents auto-close)
      opts.event_handlers = opts.event_handlers or {}
      local refresh_filesystem = function()
        vim.schedule(function()
          require("neo-tree.sources.manager").refresh("filesystem")
        end)
      end

      table.insert(opts.event_handlers, {
        event = "vim_buffer_changed",
        handler = refresh_filesystem,
      })

      table.insert(opts.event_handlers, {
        event = "file_opened",
        handler = function()
          refresh_filesystem()
          vim.schedule(function()
            require("neo-tree.command").execute({
              action = "show",
              source = "filesystem",
              position = "left",
            })
          end)
        end,
      })
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          -- Override default <Leader>e to use reveal (keeps tree state, shows current file)
          ["<Leader>e"] = {
            function()
              local manager = require("neo-tree.sources.manager")
              local state = manager.get_state("filesystem")
              if state.current_position and require("neo-tree.ui.renderer").tree_is_visible(state) then
                vim.cmd("Neotree close")
              else
                vim.cmd("Neotree filesystem reveal left")
              end
            end,
            desc = "Toggle Explorer",
          },
        },
      },
    },
  },
}
