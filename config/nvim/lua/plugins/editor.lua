return {
  -- Jumps: `s` two-char jump (was easymotion), `S` treesitter selection.
  -- <C-s> in a / search toggles jump labels (was incsearch-easymotion).
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "<leader>L", function() require("flash").jump({ search = { mode = "search", max_length = 0 }, label = { after = { 0, 0 } }, pattern = "^" }) end, desc = "Jump to line" },
      { "<C-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle flash search" },
    },
  },

  -- vim-surround muscle memory: ys{motion}{char}, yss, ds{char}, cs{old}{new},
  -- S{char} in visual mode
  {
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "ys",
        delete = "ds",
        replace = "cs",
        find = "",
        find_left = "",
        highlight = "",
        update_n_lines = "",
        suffix_last = "",
        suffix_next = "",
      },
      search_method = "cover_or_next",
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
      vim.keymap.del("x", "ys")
      vim.keymap.set(
        "x",
        "S",
        [[:<C-u>lua MiniSurround.add('visual')<cr>]],
        { silent = true, desc = "Surround selection" }
      )
      vim.keymap.set("n", "yss", "ys_", { remap = true, desc = "Surround line" })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Prev hunk")
        map({ "n", "x" }, "<leader>hs", ":Gitsigns stage_hunk<cr>", "Stage hunk")
        map({ "n", "x" }, "<leader>hr", ":Gitsigns reset_hunk<cr>", "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>ub", gs.toggle_current_line_blame, "Toggle line blame")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "GBrowse", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit" },
    dependencies = { "tpope/vim-rhubarb" },
    keys = {
      { "<leader>gb", "<cmd>GBrowse!<cr><cmd>GBrowse<cr>", desc = "Open + copy GitHub URL" },
      { "<leader>gb", ":GBrowse<cr>", mode = "x", desc = "Open GitHub URL for selection" },
    },
  },

  -- Formatting: terraform fmt on save, everything else on demand
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        go = { "goimports", "gofmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        -- ruby/yaml/json fall back to the LSP (ruby-lsp runs rubocop)
      },
      default_format_opts = { lsp_format = "fallback" },
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "terraform" or ft == "terraform-vars" then
          return { timeout_ms = 1000 }
        end
      end,
    },
  },

  -- Seamless M-hjkl between nvim splits and tmux panes (see tmux.conf)
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<M-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Pane left" },
      { "<M-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Pane down" },
      { "<M-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Pane up" },
      { "<M-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Pane right" },
      { "<M-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Previous pane" },
    },
  },

  -- `nvim file:line:col` (vfind in bashrc relies on this)
  { "kopischke/vim-fetch", lazy = false },

  -- Edit the real path behind symlinks so git/gitsigns see the dot-files repo
  { "aymericbeaumet/vim-symlink", lazy = false },

  { "fladson/vim-kitty", ft = "kitty" },
}
