-- AstroNvim pins aerial.nvim to `^2.2`, which blocks the fix for nvim 0.12's
-- removal of `iter_matches({ all = false })`. The fix landed in aerial 3.1.0
-- (commit f93dcee). Bump the constraint so lazy resolves a 3.x release.
---@type LazySpec
return {
  { "stevearc/aerial.nvim", version = "^3.1" },
}
