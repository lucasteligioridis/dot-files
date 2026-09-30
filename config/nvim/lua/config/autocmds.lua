local group = vim.api.nvim_create_augroup("config", { clear = true })
local autocmd = function(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

vim.filetype.add({
  extension = {
    tf = "terraform", -- Neovim defaults .tf to TinyFugue
    tfbackend = "terraform",
    parameters = "json",
    tags = "json",
    template = "yaml",
  },
  pattern = {
    [".*makefile.*"] = "make",
  },
})

-- Strip trailing whitespace on save without moving the cursor
autocmd("BufWritePre", {
  callback = function()
    if not vim.bo.modifiable or vim.bo.binary then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Reopen files at the last cursor position
autocmd("BufReadPost", {
  callback = function(ev)
    -- filetypedetect runs after this autocmd, so the filetype option isn't set yet
    local ft = vim.filetype.match({ buf = ev.buf }) or vim.bo[ev.buf].filetype
    if ft == "gitcommit" or ft == "gitrebase" or vim.b[ev.buf].restored_cursor then
      return
    end
    vim.b[ev.buf].restored_cursor = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

autocmd("VimResized", { command = "tabdo wincmd =" })

-- q closes throwaway windows
autocmd("FileType", {
  pattern = { "help", "qf", "checkhealth", "man", "git", "fugitiveblame" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- Per-language indentation that differs from the 2-space default
local indent = {
  go = { expandtab = false, tabstop = 4, shiftwidth = 4 },
  make = { expandtab = false, tabstop = 2, shiftwidth = 2 },
  python = { tabstop = 4, shiftwidth = 4 },
  dockerfile = { tabstop = 4, shiftwidth = 4 },
}
autocmd("FileType", {
  pattern = vim.tbl_keys(indent),
  callback = function(ev)
    for k, v in pairs(indent[ev.match]) do
      vim.bo[ev.buf][k] = v
    end
  end,
})

autocmd("FileType", {
  pattern = "terraform",
  callback = function(ev)
    vim.bo[ev.buf].commentstring = "// %s"
  end,
})
