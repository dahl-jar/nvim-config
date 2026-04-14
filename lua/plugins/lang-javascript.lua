---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "AstroFile",
        once = true,
        callback = function()
          local ok, dap = pcall(require, "dap")
          if not ok then return end

          local browser = {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch browser",
            url = function()
              local url = vim.fn.input("Browser URL: ", "http://localhost:3000")
              if url == "" then return "http://localhost:3000" end
              return url
            end,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
          }

          dap.configurations.javascript = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch current file (Node)",
              cwd = "${workspaceFolder}",
              program = "${file}",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to process (Node)",
              cwd = "${workspaceFolder}",
              processId = require("dap.utils").pick_process,
            },
            browser,
          }

          dap.configurations.typescript = {
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to process (Node)",
              cwd = "${workspaceFolder}",
              processId = require("dap.utils").pick_process,
            },
            browser,
          }

          dap.configurations.javascriptreact = dap.configurations.javascript
          dap.configurations.typescriptreact = dap.configurations.typescript
        end,
      })
    end,
  },
}
