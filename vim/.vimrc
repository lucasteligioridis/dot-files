" package manager
execute pathogen#infect()

" global variables to enable plugins
syntax on
syntax enable
filetype plugin indent on
set mouse=a
set clipboard=unnamed

" very basic editor behaviour
set number    " line numbers
set expandtab " tabs -> spaces
set tabstop=2
set wrap

" bash like tab completion
set wildmode=longest,list,full
set wildmenu

" nuke all trailing space before a write
au BufWritePre * :%s/\s\+$//e

" permanent undo history of files
let s:undoDir = "/home/lucast/.vim/undo"
let &undodir=s:undoDir
set undofile

" Shorctuts & key bindings --------------------------------

" move entire pane one line at a time
map <S-Up> <C-y>
map <S-Down> <C-e>
inoremap <S-Up> <C-x><C-y>
inoremap <S-Down> <C-x><C-e>

" Map Ctrl-Backspace to delete the previous word in insert mode.
map   <C-W>
imap  <C-W>

" re-launch vim as sudo
cmap w!! w !sudo tee % >/dev/null

" Move across panes
map <S-M-Left>  <C-W><left>
map <S-M-Right> <C-W><right>
map <S-M-Up>    <C-W><up>
map <S-M-Down>  <C-W><down>

" Tab settings
map  <C-T>     :tabnew<CR>:e
nmap <C-T>     :tabnew<CR>:e
imap <C-T>     <Esc>:tabnew<CR>:e
nmap ^[[1;2D   :tabp<CR>
nmap ^[[1;2C   :tabn<CR>
imap ^[[1;2D   <Esc>:tabp<CR>
imap ^[[1;2C   <Esc>:tabn<CR>
imap <S-Left>  <Esc>:tabp<CR>
map  <S-Left>  <Esc>:tabp<CR>
imap <S-Right> <Esc>:tabn<CR>
map  <S-Right> <Esc>:tabn<CR>
set showtabline=2
set tabpagemax=500
highlight TabLine       ctermfg=green ctermbg=None cterm=None
highlight TabLineFill   ctermfg=white ctermbg=None cterm=None
highlight TabLineSel    ctermfg=202

" Resize panes
map <C-D-left> <C-W><<>
map <C-D-right> :vertical resize -20<CR>

" tmux and vim combination
if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" fuzzy completion
"set rtp+=/.fzf

" COLOURS AND TMUX
if (has("termguicolors"))
    set termguicolors
endif

set background=dark
set t_Co=256

" Color scheme
colorscheme onedark

" NERDTree settings, open NERDTree by default
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <C-B> :NERDTreeFocus<CR>
noremap <C-Bslash> :NERDTreeToggle<CR>

" Disable editor mode in default bar
set noshowmode

" Detect file encoding
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
    endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Required
set encoding=utf8

" Status bar and devicon settings
let g:airline_powerline_fonts = 1
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_airline_tabline = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '

syn match NERDTreeTxtFile #^\s\+.*txt$#
highlight NERDTreeTxtFile ctermbg=red ctermfg=magenta

" enable syntax checking
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_exec = 'python3'
let g:syntastic_python_flake8_args = ['-m', 'flake8']

" Enable autocompletion
let g:neocomplete#enable_at_startup = 1

" Terraform
let g:terraform_align=1
let g:terraform_fold_sections=1
let g:terraform_remap_spacebar=1
autocmd FileType terraform setlocal commentstring=//%s

" Language-specific formatting
autocmd FileType go   setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType py   setlocal autoindent expandtab   tabstop=4 shiftwidth=4
autocmd FileType rb   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType sh   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType zsh  setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType make setlocal autoindent noexpandtab tabstop=2 shiftwidth=2
