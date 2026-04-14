-- Add persistent diagnostic counts to the statusline

return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require("astroui.status")

    -- Insert a diagnostic count component into the statusline
    -- Find the default statusline and add diagnostics to it
    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      status.component.mode(),
      status.component.git_branch(),
      status.component.file_info(),
      status.component.git_diff(),
      status.component.diagnostics {
        surround = { separator = "left" },
        padding = { left = 1, right = 1 },
      },
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.virtual_env(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
    }
  end,
}
