-- Plugin keymaps live with their plugin spec; LSP uses the Neovim defaults
-- (grn rename, gra code action, grr references, gri implementation,
-- grt type definition, gO symbols, K hover, [d ]d diagnostics).
local map = vim.keymap.set

-- Fat-finger quits, only when typed as a whole ':' command (not in searches)
for lhs, rhs in pairs({ Q = "q", ["Q!"] = "q!", Q1 = "q!", q1 = "q!", Wq = "wq", W = "w" }) do
  map("ca", lhs, function()
    return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs) and rhs or lhs
  end, { expr = true })
end

map("n", "Q", "<cmd>q<cr>", { desc = "Quit window" })
map("n", ";", ":", { desc = "Command line" })
map({ "n", "x" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save" })
map("i", "<C-s>", "<esc><cmd>write<cr>", { desc = "Save" })

-- Buffers (C-h/C-l used to be tabs)
map("n", "<C-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<C-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Paste on a new line below
map("n", "<F4>", "o<esc>p", { desc = "Paste below line" })

-- Keep selection when indenting
map("x", "<", "<gv")
map("x", ">", ">gv")
