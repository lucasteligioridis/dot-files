local opt = vim.opt

-- PATH: mise shims first so project-pinned tools win (terraform, ruby, node…),
-- Mason's bin last as the fallback for LSPs/formatters not installed elsewhere.
vim.env.PATH = vim.env.HOME
  .. "/.local/share/mise/shims:"
  .. vim.env.PATH
  .. ":"
  .. vim.fn.stdpath("data")
  .. "/mason/bin"

-- Providers: nothing needs perl/ruby/node remote plugins, skip probing them.
-- Python keeps a dedicated venv independent of mise project versions:
--   python3 -m venv ~/.local/share/nvim/python-venv
--   ~/.local/share/nvim/python-venv/bin/pip install pynvim
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
local python_venv = vim.fn.expand("~/.local/share/nvim/python-venv/bin/python")
if vim.fn.executable(python_venv) == 1 then
  vim.g.python3_host_prog = python_venv
else
  vim.g.loaded_python3_provider = 0
end

-- General
opt.mouse = "a"
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.undodir = vim.fn.expand("~/.vim/undo") -- keep existing undo history
opt.undolevels = 10000

-- Deferred: the clipboard provider probe is the slowest bit of startup
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.inccommand = "split"
opt.grepprg = "rg --vimgrep --smart-case --hidden"
opt.grepformat = "%f:%l:%c:%m"

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.showmode = false -- lualine shows it
opt.laststatus = 3
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.winborder = "rounded"
opt.pumheight = 12
opt.smoothscroll = true
opt.fillchars = { eob = " " }
opt.list = true
opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }
opt.shortmess:append({ c = true, I = true })

-- Editing
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.textwidth = 0
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.virtualedit = "block"

-- Command-line completion
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.pyc", "*.o", "*.class", "*.DS_Store", "*.min.*", "__pycache__" })

-- Folding via treesitter, all open by default
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
