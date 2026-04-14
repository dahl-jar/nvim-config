-- Markdown reader mode: rendered markdown + clean reading layout
-- Toggle with <Leader>mv

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      enabled = false, -- off by default, toggled via <Leader>mv
      render_modes = { "n", "c" },
      heading = {
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 2,
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.n = opts.mappings.n or {}
      opts.mappings.n["<Leader>mv"] = {
        function()
          if vim.bo.filetype ~= "markdown" then
            vim.notify("Markdown reader works in markdown buffers only", vim.log.levels.INFO)
            return
          end

          local rm = require("render-markdown")
          local state = require("render-markdown.state")

          if vim.b.markdown_reader_mode then
            -- Turn OFF: restore previous settings
            rm.disable()
            local prev = vim.b.markdown_reader_prev or {}
            for option, value in pairs(prev) do
              vim.opt_local[option] = value
            end
            vim.b.markdown_reader_mode = false
            vim.b.markdown_reader_prev = nil
            vim.notify("Reader mode: OFF", vim.log.levels.INFO)
          else
            -- Turn ON: save current settings, apply reader layout + rendering
            vim.b.markdown_reader_prev = {
              wrap = vim.wo.wrap,
              linebreak = vim.wo.linebreak,
              number = vim.wo.number,
              relativenumber = vim.wo.relativenumber,
              signcolumn = vim.wo.signcolumn,
              cursorline = vim.wo.cursorline,
              list = vim.wo.list,
              conceallevel = vim.wo.conceallevel,
              concealcursor = vim.wo.concealcursor,
              fillchars = vim.wo.fillchars,
            }
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            vim.opt_local.cursorline = false
            vim.opt_local.list = false
            vim.opt_local.conceallevel = 2
            vim.opt_local.concealcursor = "nc"
            vim.opt_local.fillchars = "eob: "
            rm.enable()
            vim.b.markdown_reader_mode = true
            vim.notify("Reader mode: ON", vim.log.levels.INFO)
          end
        end,
        desc = "Toggle Markdown Reader Mode",
      }
    end,
  },
}
