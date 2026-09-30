-- nvim-treesitter `main` branch: it only installs parsers/queries, highlighting
-- and indent are switched on per buffer below. Needs the `tree-sitter` CLI.
local parsers = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "embedded_template",
  "git_config",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "graphql",
  "hcl",
  "html",
  "java",
  "javascript",
  "json",
  "json5",
  "kotlin",
  "lua",
  "luadoc",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rego",
  "ruby",
  "rust",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

-- Treesitter indent is weaker than the runtime indent scripts for these
local no_ts_indent = { ruby = true, yaml = true, markdown = true }

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- the main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
      callback = function(ev)
        if not pcall(vim.treesitter.start, ev.buf) then
          return
        end
        if not no_ts_indent[ev.match] then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
