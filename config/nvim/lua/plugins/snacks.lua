-- Picker, explorer, indent guides, zen mode, notifications and friends
local function tmux_status(state)
  if vim.env.TMUX then
    vim.fn.system({ "tmux", "set", "status", state })
  end
end

local function explorer()
  return Snacks.picker.get({ source = "explorer" })[1]
end

-- <leader>n: open the tree, or close it if it's already open
local function explorer_toggle()
  local picker = explorer()
  if picker then
    picker:close()
  else
    Snacks.explorer()
  end
end

-- Keep the tree open like NERDTree used to: open it on startup (focus stays
-- on the file) and quit Neovim when the last real window is closed.
local function explorer_autocmds()
  local group = vim.api.nvim_create_augroup("config_explorer", { clear = true })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      local ft = vim.bo.filetype
      if vim.o.diff or vim.g.read_from_stdin or ft == "gitcommit" or ft == "gitrebase" then
        return
      end
      local picker = explorer()
      if picker then
        -- `nvim <dir>`: snacks opened and focused the tree, move to the editor
        vim.schedule(function()
          if picker.main and vim.api.nvim_win_is_valid(picker.main) then
            vim.api.nvim_set_current_win(picker.main)
          end
        end)
        return
      end
      Snacks.explorer({ enter = false })
    end,
  })

  vim.api.nvim_create_autocmd("StdinReadPre", {
    group = group,
    callback = function()
      vim.g.read_from_stdin = true
    end,
  })

  -- Once the last real window closes, don't leave a tree-only Neovim behind
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function()
      vim.schedule(function()
        if not explorer() then
          return
        end
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if
            vim.api.nvim_win_get_config(win).relative == ""
            and not vim.bo[buf].filetype:match("^snacks_")
          then
            return -- a real window remains
          end
        end
        vim.cmd("qall") -- 'confirm' prompts for unsaved buffers
      end)
    end,
  })
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  config = function(_, opts)
    require("snacks").setup(opts)
    explorer_autocmds()
  end,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    words = { enabled = true }, -- highlight LSP references under cursor
    indent = { enabled = true, animate = { enabled = false } },
    explorer = { enabled = true, replace_netrw = true },
    zen = {
      on_open = function()
        tmux_status("off")
      end,
      on_close = function()
        tmux_status("on")
      end,
    },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        explorer = { hidden = true, ignored = true },
      },
    },
  },
  -- stylua: ignore
  keys = {
    -- Kept from the fzf.vim days
    { "<leader><leader>", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>F", function() Snacks.picker.files({ ignored = true }) end, desc = "Find files (incl. ignored)" },
    { "<leader><cr>", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep project" },
    { "<leader>;", function() Snacks.picker.lines() end, desc = "Buffer lines" },
    { "<leader>.", function() Snacks.picker.grep_buffers() end, desc = "Grep open buffers" },
    { "<leader>?", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>o", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
    { "<leader>O", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
    { "<leader>`", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>p", function() Snacks.picker.resume() end, desc = "Resume last picker" },
    { "<leader>y", function() Snacks.picker.registers() end, desc = "Registers" },
    { "<leader>n", explorer_toggle, desc = "Toggle file explorer" },
    { "<leader>G", function() Snacks.zen() end, desc = "Zen mode" },
    -- Search
    { "<leader>sw", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep word/selection" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help pages" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command history" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo history" },
    { "<leader>sn", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    -- Git
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
    { "<leader>ga", function() Snacks.picker.git_log_file() end, desc = "Git log (file)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
    -- Buffers
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
    -- LSP references highlighted by snacks.words
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference" },
  },
}
