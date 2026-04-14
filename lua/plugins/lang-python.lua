---@type LazySpec
local function executable(path)
  return path and path ~= "" and vim.fn.executable(path) == 1
end

local function python_from_root(root)
  if not root or root == "" then return nil end

  for _, path in ipairs({ root .. "/.venv/bin/python", root .. "/venv/bin/python" }) do
    if executable(path) then return path end
  end
end

local function resolve_python(root)
  local from_env = vim.env.VIRTUAL_ENV
  if from_env and from_env ~= "" then
    local path = from_env .. "/bin/python"
    if executable(path) then return path end
  end

  local from_root = python_from_root(root)
  if from_root then return from_root end

  local from_cwd = python_from_root(vim.fn.getcwd())
  if from_cwd then return from_cwd end

  local python3 = vim.fn.exepath "python3"
  if executable(python3) then return python3 end

  local python = vim.fn.exepath "python"
  if executable(python) then return python end

  return "python3"
end

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    opts = {
      config = {
        basedpyright = {
          before_init = function(_, config)
            if not config.settings then config.settings = {} end
            if not config.settings.python then config.settings.python = {} end

            config.settings.python.pythonPath = resolve_python(config.root_dir)
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    optional = true,
    config = function(_, opts)
      local dap_python = require "dap-python"
      dap_python.resolve_python = function() return resolve_python() end
      dap_python.setup("uv", opts)
    end,
  },
}
