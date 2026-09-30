-- Native LSP: nvim-lspconfig only supplies the per-server defaults (lsp/*.lua),
-- everything here overrides or extends them via vim.lsp.config.

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      staticcheck = true,
      usePlaceholders = true,
      analyses = { unusedparams = true, unusedwrite = true },
    },
  },
})

-- terraform-ls semantic tokens drift after a buffer is reloaded from disk
-- (external edits, git checkouts), painting colours mid-word and on comments.
-- Treesitter already highlights HCL fully, so only use the LSP for the rest.
vim.lsp.config("terraformls", {
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

vim.lsp.config("yamlls", {
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
      -- HomeAssistant YAML tags
      customTags = {
        "!include scalar",
        "!include_dir_list scalar",
        "!include_dir_named scalar",
        "!include_dir_merge_list scalar",
        "!include_dir_merge_named scalar",
        "!secret scalar",
        "!env_var scalar",
        "!input scalar",
      },
    },
  },
})

vim.lsp.config("basedpyright", {
  settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
})

-- Sorbet only in projects that actually use it (sorbet/config present), run
-- through the project's bundle so it matches the Gemfile.lock version.
vim.lsp.config("sorbet", {
  cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, function(name, path)
      return name == "sorbet" and vim.uv.fs_stat(path .. "/sorbet/config") ~= nil
    end)
    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.enable({
  "basedpyright",
  "bashls",
  "dockerls",
  "gopls",
  "jsonls",
  "lua_ls",
  "sorbet",
  "terraformls",
  "tflint",
  "yamlls",
})

-- ruby-lsp manages its own composed bundle per project; it needs a Ruby >= 3
-- install (e.g. `gem install ruby-lsp` under mise), so only enable when present.
if vim.fn.executable("ruby-lsp") == 1 then
  vim.lsp.enable("ruby_lsp")
end

vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
  float = { source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "●",
      [vim.diagnostic.severity.WARN] = "●",
      [vim.diagnostic.severity.INFO] = "●",
      [vim.diagnostic.severity.HINT] = "●",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config_lsp", { clear = true }),
  callback = function(ev)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("gd", function()
      Snacks.picker.lsp_definitions()
    end, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("gy", function()
      Snacks.picker.lsp_type_definitions()
    end, "Goto type definition")
    map("<leader>cl", vim.lsp.codelens.run, "Run codelens")
    map("<leader>uh", function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
        { bufnr = ev.buf }
      )
    end, "Toggle inlay hints")
  end,
})
