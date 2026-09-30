-- Everything Mason keeps installed. Tools already on PATH (brew/mise) take
-- precedence at runtime; these make a fresh machine work out of the box.
-- Ruby tooling (ruby-lsp, sorbet, rubocop) comes from each project's bundle.
local tools = {
  "basedpyright",
  "bash-language-server",
  "dockerfile-language-server",
  "goimports",
  "gopls",
  "json-lsp",
  "lua-language-server",
  "ruff",
  "shellcheck",
  "shfmt",
  "stylua",
  "terraform-ls",
  "tflint",
  "yaml-language-server",
}

return {
  -- Server defaults only (cmd/filetypes/root markers); config is in config/lsp.lua
  { "neovim/nvim-lspconfig", lazy = false },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    event = "VeryLazy",
    opts = { PATH = "skip" }, -- appended in config/options.lua
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pcall(pkg.install, pkg)
          end
        end
      end)
    end,
  },

  -- Neovim runtime + plugin types for lua_ls when editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
