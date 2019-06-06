" ============================================================================
" Vim-plug initialization

" Create the autocmd group used by all my autocmds (cleared when sourcing vimrc)
augroup vimrc
  autocmd!
augroup END

" This has to be before everything else because the rest only works if vim-plug
" is installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ============================================================================
" Active plugins

" this needs to be here, so vim-plug knows we are declaring the plugins we
" want to use
call plug#begin('~/.local/share/nvim/plugged')
filetype plugin on
filetype plugin indent on

" Features
Plug 'scrooloose/nerdtree'                                        " File tree browser
Plug 'scrooloose/nerdcommenter'                                   " Code commenter
Plug 'w0rp/ale'                                                   " Code linter
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'                    " Syntax highlighting file tree
Plug 'Xuyuanp/nerdtree-git-plugin'                                " Git for NerdTree
Plug 'jistr/vim-nerdtree-tabs'                                    " NerdTree independent of tabs
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Install fzf for user
Plug 'junegunn/fzf.vim'                                           " Fzf vim plugin
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}        " coc.nvim autocomplete

" Small utilities
Plug 'bag-man/copypath.vim'                                       " Copy path of file
Plug 'rbgrouleff/bclose.vim'                                      " Close current buffer
Plug 'can3p/incbool.vim'                                          " Toggle true/false
Plug 'kopischke/vim-fetch'                                        " Use line numbers in file paths
Plug 'matze/vim-move'                                             " Move lines up and down
Plug 'takac/vim-hardtime'                                         " Hardcore vim
Plug 'christoomey/vim-tmux-navigator'                             " Naviagte between tmux seamlessly
Plug 'tmux-plugins/vim-tmux-focus-events'                         " Enable tmux focused events
Plug 'airblade/vim-gitgutter'                                     " Git integration

" Efficiency
Plug 'godlygeek/tabular'                                          " Better tab
Plug 'easymotion/vim-easymotion'                                  " Move around vim faster
Plug 'junegunn/vim-easy-align'                                    " Align text
Plug 'junegunn/vim-peekaboo'                                      " Register extender
Plug 'jiangmiao/auto-pairs'                                       " Auto pairs

" Languages
Plug 'sheerun/vim-polyglot'                                       " Better language pack
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries'  }               " Syntax for go
Plug 'hashivim/vim-terraform'                                     " Syntax for terraform
Plug 'ekalinin/Dockerfile.vim'                                    " Syntax for docker

" tpope
Plug 'tpope/vim-surround'                                         " Operate on surrounding
Plug 'tpope/vim-repeat'                                           " Repeat plugins
Plug 'tpope/vim-commentary'                                       " Comment out blocks
Plug 'tpope/vim-fugitive'                                         " Git integration
Plug 'tpope/vim-abolish'                                          " Flexible search
Plug 'tpope/vim-obsession'                                        " Autosave vim sessions
Plug 'dhruvasagar/vim-prosession'                                 " Addon to vim-obsession

" Appearance
Plug 'joshdick/onedark.vim'                                       " Onedark color scheme
Plug 'ryanoasis/vim-devicons'                                     " Better icon packs
Plug 'vim-airline/vim-airline'                                    " Airline
Plug 'vim-airline/vim-airline-themes'                             " Airline themes
Plug 'Yggdroot/indentLine'                                        " Show indented lines

" Writing mode
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/seoul256.vim'
Plug 'reedes/vim-pencil'
Plug 'rhysd/vim-grammarous'

call plug#end()

" ============================================================================
" Install missing plugins automatically on startup

autocmd vimrc VimEnter *
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q | runtime vimrc
      \| endif

" ============================================================================
" Bootstrap configuration

" global variables to enable plugins
syntax on
syntax enable
set nocompatible

" enable mouse
set mouse=a

" use system clipboard
set clipboard=unnamed
set clipboard=unnamedplus

" search settings
set incsearch
set smartcase
set ignorecase
set nohlsearch

" very basic editor behaviour
set number    " line numbers
set expandtab " tabs -> spaces
set tabstop=2
set wrap
set list lcs=tab:\▏\ " add indent line for tabs

" bash like tab completion
set wildmode=longest,list,full
set wildmenu
set wildignore+=*.pyc,*.o,*.obj,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.*,*.git,__pycache__

" nuke all trailing space before a write
au BufWritePre * :%s/\s\+$//e

" put cursor back where it was last time when re-opening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" enable syntax entire file
autocmd BufEnter * :syntax sync fromstart

" set dash as a word boundary
set iskeyword-=-

" Undo

" permanent undo history of files
set undodir=/home/lucast/.vim/undo
set undofile

" Automatically create directory for undo if it does not exist
if !isdirectory(expand('~').'/.vim/undo')
  !mkdir -p $HOME/.vim/undo
endif

" Backup

" turn on backup
set backup
set backupdir=/home/lucast/.vim/tmp/

" Swap

" enable swapfile
set swapfile
set directory=/home/lucast/.vim/swap

" Automatically create directory for swapfiles if it does not exist
if !isdirectory(expand('~').'/.vim/swap')
  !mkdir -p $HOME/.vim/swap
endif

" fuzzy completion
set runtimepath+=/.fzf

" set utf8 encoding by default
set encoding=utf8

" set some tab highlighting
set showtabline=2
set tabpagemax=500
highlight TabLine       ctermfg=green ctermbg=None cterm=None
highlight TabLineFill   ctermfg=white ctermbg=None cterm=None
highlight TabLineSel    ctermfg=202

" Grammar checking
" let g:grammarous#default_comments_only_filetypes = {
"             \ '*' : 1, 'help' : 0, 'markdown' : 0,
"             \ }

" Enable hard modeline
let g:hardtime_default_on = 0

" ============================================================================
" Shorctuts & key bindings

if !has('nvim')
  set ttymouse=xterm2
  " make redrawing smoother
  set ttyfast
endif

" Time out mapping after 100ms
if !has('nvim') && &ttimeoutlen == -1
  set ttimeout
  set ttimeoutlen=100
endif

" Remap leader key
let mapleader = "\<Space>"

" move entire pane one line at a time
map <S-Up> <C-y>
map <S-Down> <C-e>
inoremap <S-Up> <C-x><C-y>
inoremap <S-Down> <C-x><C-e>

" Map Ctrl-Backspace to delete the previous word in insert mode
map  <C-W>
imap  <C-W>
map <C-BS> <C-W>
imap <C-BS> <C-W>

" re-launch vim as sudo
cmap w!! w !sudo tee % >/dev/null

" Tab settings
map  <silent><C-T>     :tabnew<CR>i
nmap <silent><C-T>     :tabnew<CR>i
imap <silent><C-T>     <Esc>:tabnew<CR>i
nmap <silent>^[[1;2D   :tabp<CR>
nmap <silent>^[[1;2C   :tabn<CR>
imap <silent>^[[1;2D   <Esc>:tabp<CR>
imap <silent>^[[1;2C   <Esc>:tabn<CR>
imap <silent><S-Left>  <Esc>:tabp<CR>
map  <silent><S-Left>  <Esc>:tabp<CR>
imap <silent><S-Right> <Esc>:tabn<CR>
map  <silent><S-Right> <Esc>:tabn<CR>

" quit/exit shortcuts fat fingers
cabbrev Q q
cabbrev Q! q!
cabbrev Q1 q!
cabbrev q1 q!
cabbrev Wq wq
map Y y$
map Q :q<CR>

" save shortcuts
map <C-s> :w!<CR>
imap <C-s> <ESC>:w!<CR>

" fzf
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_layout = { 'down': '~20%' }

" Take colours from colour scheme
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Hide statusline and mode indicator in fzf
autocmd! FileType fzf
autocmd FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:fzf_nvim_statusline = 0 " disable statusline overwriting

" Smart shortcuts
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>a :Buffers<CR>
nnoremap <silent> <leader>A :Windows<CR>
nnoremap <silent> <leader>; :BLines<CR>
nnoremap <silent> <leader>o :BTags<CR>
nnoremap <silent> <leader>O :Tags<CR>
nnoremap <silent> <leader>? :History<CR>
nnoremap <silent> <leader>/ :execute 'Rg ' . input('Rg/')<CR>
nnoremap <silent> <leader>. :RgIn

nnoremap <silent> K :call SearchWordWithRg()<CR>
vnoremap <silent> K :call SearchVisualSelectionWithRg()<CR>
nnoremap <silent> <leader>gl :Commits<CR>
nnoremap <silent> <leader>ga :BCommits<CR>
nnoremap <silent> <leader>ft :Filetypes<CR>

imap <C-x><C-f> <plug>(fzf-complete-file-ag)
imap <C-x><C-l> <plug>(fzf-complete-line)

" Use ripgrep to search for strings
function! SearchWordWithRg()
  execute 'Rg' expand('<cword>')
endfunction

function! SearchVisualSelectionWithRg() range
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  let old_clipboard = &clipboard
  set clipboard&
  normal! ""gvy
  let selection = getreg('"')
  call setreg('"', old_reg, old_regtype)
  let &clipboard = old_clipboard
  execute 'Rg' selection
endfunction

function! SearchWithRgInDirectory(...)
  call fzf#vim#ag(join(a:000[1:], ' '), extend({'dir': a:1}, g:fzf#vim#default_layout))
endfunction
command! -nargs=+ -complete=dir RgIn call SearchWithRgInDirectory(<f-args>)

" Paste below line
nmap <F4> o<ESC>p

" Grammar checker
nmap <F5> :GrammarousCheck<return>

" swap semi-colon for cmd mode
nmap ; :

" ============================================================================
" Tmux

" tmux and vim combination
if &term =~# '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" autocomplete
if exists('$TMUX')
    " Tmux completion (with tmux-complete plugin)
    let g:tmuxcomplete#trigger = ''
endif

" Pane switching
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-\> :TmuxNavigatePrevious<cr>

" ============================================================================
" Colours and themes

if (has('termguicolors'))
    set termguicolors
endif

" Enable 256 colours
set background=dark
set t_Co=256

" Color scheme
colorscheme onedark

" Highlight and underline on 80 characters
autocmd BufWinEnter * match SpellBad /\%>79v.*\%<81v/

" ============================================================================
" Interface

" NERDTree ----------------------------------
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') | q | endif
nmap <silent><F6> :NERDTreeToggle<CR>
syn match NERDTreeTxtFile #^\s\+.*txt$#
highlight NERDTreeTxtFile ctermbg=red ctermfg=magenta
let NERDTreeRespectWildIgnore=1

" Show hidden files
let NERDTreeShowHidden=1

" Disable editor mode in default bar
set noshowmode

" Detect file encoding
if has('multi_byte')
  if &termencoding ==# ''
    let &termencoding = &encoding
    endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Airline -----------------------------
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_airline_tabline = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '

" Line number -------------------------
set number
set relativenumber
set cursorline

" Indent line symbols -----------------
let g:indentLine_enabled = 1
let g:indentLine_char = '▏'

" Move modified -----------------------
let g:move_key_modifier = 'A-S'

" Vim easymotion ----------------------
" type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1
" disable default mappings
let g:EasyMotion_do_mapping = 0
" Smartsign (type `3` and match `3`&`#`)
let g:EasyMotion_use_smartsign_us = 1
" Jump to first match with enter & space
let g:EasyMotion_enter_jump_first = 1
let g:EasyMotion_space_jump_first = 1

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Gif config
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
map n <Plug>(easymotion-next)
map N <Plug>(easymotion-prev)

" Vim easyalign
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Limelight
let g:limelight_paragraph_span = 1  " Don't dim one par around the current one
let g:limelight_priority       = -1 " Don't overrule hlsearch

" ============================================================================
" Autocomplete

" Python -------------------------------
let g:python3_host_prog = '/home/lucast/.pyenv/versions/3.6.4/bin/python3'

set pumheight=15
set completeopt=menuone,noinsert,noselect

" Markdown -------------------------------
let g:vim_markdown_conceal = 0

" Coc-vim --------------------------------
" if hidden is not set, TextEdit might fail.
set hidden

" Better display for messages
set cmdheight=2

" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" ============================================================================
" Syntax highlighting and linting

" Ale -------------------------------
let g:ale_open_list = 1
let g:airline#extensions#ale#enabled = 1

augroup CloseLoclistWindowGroup
  autocmd!
  autocmd QuitPre * if empty(&buftype) | lclose | endif
augroup END

" Fugitive --------------------------
set statusline+=%{FugitiveStatusline()}

" Terraform -------------------------
let g:terraform_align=1
let g:terraform_completion_keys = 1
autocmd FileType terraform setlocal commentstring=//%s

" Ansible ---------------------------
" let g:ansible_attribute_highlight = "ob"
let g:ansible_unindent_after_newline = 1
let g:ansible_extra_keywords_highlight = 1

" File extension --------------------
" Language-specific formatting
autocmd FileType go         setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType py         setlocal autoindent expandtab   tabstop=4 shiftwidth=4
autocmd FileType rb         setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType sh         setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType zsh        setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType make       setlocal autoindent noexpandtab tabstop=2 shiftwidth=2
autocmd FileType yaml       setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType groovy     setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType dockerfile setlocal autoindent expandtab   tabstop=4 shiftwidth=4

" File type formatting
au BufRead,BufNewFile *.tf         setlocal filetype=terraform
au BufRead,BufNewFile *.tfvars     setlocal filetype=terraform
au BufRead,BufNewFile *.tfstate    setlocal filetype=javascript
au BufRead,BufNewFile *.parameters setlocal filetype=json
au BufRead,BufNewFile *.tags       setlocal filetype=json
au BufRead,BufNewFile *.template   setlocal filetype=yaml
au BufRead,BufNewFile Dockerfile.* setlocal filetype=dockerfile
au BufRead,BufNewFile Jenkinsfile  setlocal filetype=groovy
au BufRead,BufNewFile *makefile*   setlocal filetype=make
