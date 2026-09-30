# Neovim

Lua config for Neovim 0.12+. Plugins via lazy.nvim (`lazy-lock.json` is
committed), LSP and diagnostics are native (`vim.lsp.config`/`vim.lsp.enable`),
nvim-lspconfig only supplies server defaults.

```
init.lua              leader, then loads lua/config/*
lua/config/options    settings, PATH (mise shims first, Mason bin last)
lua/config/keymaps    non-plugin keymaps
lua/config/autocmds   filetypes, trim whitespace, restore cursor, indents
lua/config/lsp        server overrides, enabled servers, diagnostics
lua/plugins/*         lazy.nvim specs, one file per area
```

Install: `make install-configs` symlinks this directory to `~/.config/nvim`.
First launch installs plugins, treesitter parsers (needs `tree-sitter-cli`)
and the Mason tools listed in `lua/plugins/lsp.lua`.

Ruby: `ruby-lsp` is used when on PATH (`gem install ruby-lsp` under a mise
Ruby >= 3); Sorbet starts only in projects with `sorbet/config`, via
`bundle exec srb tc --lsp`.

## Keys

Leader is `<Space>`. `<Space>` alone shows everything (which-key).

| Key | Action |
| --- | --- |
| `<leader><leader>` / `<leader>F` | files / files incl. gitignored |
| `<leader><CR>` | buffers |
| `<leader>/` / `<leader>sw` | live grep / grep word or selection |
| `<leader>;` / `<leader>.` | lines in buffer / grep open buffers |
| `<leader>?` / `<leader>p` | recent files / resume last picker |
| `<leader>o` / `<leader>O` | document / workspace symbols |
| `<leader>n` | file explorer |
| `<leader>sd` `sD` `sh` `sk` `su` | diagnostics, buffer diagnostics, help, keymaps, undo tree |
| `<leader>gl` `ga` `gs` `gb` | git log, file log, status, GBrowse (copy + open) |
| `]h` `[h` `<leader>hs` `hr` `hp` `hb` | hunks: next/prev, stage, reset, preview, blame |
| `C-h` / `C-l` | previous / next buffer |
| `<leader>bd` / `<leader>bo` | delete buffer / delete others |
| `M-h/j/k/l` | move across splits and tmux panes |
| `s` / `S` | flash jump / treesitter select; `C-s` in `/` toggles labels |
| `<leader>L` | jump to line |
| `ys{motion}{c}` `yss` `ds{c}` `cs{old}{new}`, visual `S` | surround |
| `<leader>cf` | format (terraform also formats on save) |
| `<leader>G` | zen mode (hides tmux status) |

LSP uses the Neovim defaults plus a few extras:

| Key | Action |
| --- | --- |
| `gd` / `gD` / `gy` | definition / declaration / type definition |
| `grr` `gri` `grt` | references, implementation, type definition |
| `grn` / `gra` | rename / code action |
| `K` / `gO` | hover / document symbols |
| `[d` `]d` / `C-w d` | prev/next diagnostic / diagnostic float |
| `]]` `[[` | next/prev reference of word under cursor |
| `<leader>cl` / `<leader>uh` | run codelens / toggle inlay hints |
| `gc{motion}` / `gcc` | comment |

Completion (blink.cmp): `Tab`/`S-Tab` to move, `Enter` to accept, `C-space`
to open, `C-e` to close.
