" ============================================================================
" Vim-plug initialization

let vim_plug_just_installed = 0
let vim_plug_path = expand('~/.config/nvim/autoload/plug.vim')
if !filereadable(vim_plug_path)
    echo "Installing Vim-plug..."
    echo ""
    silent !mkdir -p ~/.config/nvim/autoload
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let vim_plug_just_installed = 1
endif

" manually load vim-plug the first time
if vim_plug_just_installed
    :execute 'source '.fnameescape(vim_plug_path)
endif

" ============================================================================
" Active plugins

" this needs to be here, so vim-plug knows we are declaring the plugins we
" want to use
call plug#begin('~/.local/share/nvim/plugged')

" Vim HardTime
Plug 'takac/vim-hardtime'

" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Python autocomplete
Plug 'davidhalter/jedi-vim'
Plug 'zchee/deoplete-jedi'

" Go autocomplete
Plug 'zchee/deoplete-go', { 'do': 'make'}

" Shougo deoplete prereqs
Plug 'Shougo/neco-vim'
Plug 'Shougo/neosnippet.vim'

" Code commenter
Plug 'scrooloose/nerdcommenter'

" File browswer
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Better language packs
Plug 'sheerun/vim-polyglot'

" Tab
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'

" Indent lines
Plug 'Yggdroot/indentLine'

" Syntax checker
Plug 'vim-syntastic/syntastic'

" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'Shougo/neosnippet-snippets'

" Git plugins
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Go syntax
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries'  }

" Grammar checker
Plug 'rhysd/vim-grammarous'

" Json syntax
Plug 'elzr/vim-json'

" Surround
Plug 'tpope/vim-surround'

" Automatically sort python imports
Plug 'fisadev/vim-isort'

" Terraform
Plug 'hashivim/vim-terraform'
Plug 'Raimondi/delimitMate'

" Docker
Plug 'ekalinin/Dockerfile.vim'

" Theme
Plug 'joshdick/onedark.vim'
Plug 'ryanoasis/vim-devicons'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Fuzzy searchers
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Easymotion
Plug 'easymotion/vim-easymotion'

" Tmux
Plug 'wellle/tmux-complete.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'

" Async completer
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'

" Linters
Plug 'neomake/neomake'

" Autosave vim session
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'

" Tell vim-plug we finished declaring plugins, so it can load them
call plug#end()

" ============================================================================
" Install plugins the first time vim runs

if vim_plug_just_installed
    echo "Installing Bundles, please ignore key map error messages"
    :PlugInstall
endif

" ============================================================================
" Bootstrap configuration

" global variables to enable plugins
syntax on
syntax enable
filetype plugin on
filetype plugin indent on

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

" permanent undo history of files
let s:undoDir = $HOME."/.vim/undo"
let &undodir=s:undoDir
set undofile

" turn on backup
set backup
set backupdir=/home/lucast/.vim/tmp/
set dir=/home/lucast/.vim/tmp/

" fuzzy completion
set rtp+=/.fzf

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

" Resize panes
map <C-D-left> <C-W><<>
map <C-D-right> :vertical resize -20<CR>

" fzf
map <C-f> :FZF<CR>
let g:fzf_layout = { 'down': '~20%' }

" Paste below line
nmap <F4> o<ESC>p

" Grammar checker
nmap <F5> :GrammarousCheck<return>

" swap semi-colon for cmd mode
nmap ; :

" ============================================================================
" Tmux

" tmux and vim combination
if &term =~ '^screen'
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

if (has("termguicolors"))
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
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
nmap <silent><F6> :NERDTreeToggle<CR>
syn match NERDTreeTxtFile #^\s\+.*txt$#
highlight NERDTreeTxtFile ctermbg=red ctermfg=magenta
let NERDTreeRespectWildIgnore=1

" Show hidden files
let NERDTreeShowHidden=1

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

" Airline -----------------------------
let g:airline_powerline_fonts = 1
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_airline_tabline = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '

" Line number -------------------------
set number
set relativenumber
set cursorline

" Indent line symbols -----------------
let g:indentLine_enabled = 1
let g:indentLine_char = "▏"

" Vim easymotion
 " type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1
" Smartsign (type `3` and match `3`&`#`)
let g:EasyMotion_use_smartsign_us = 1

" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)
nmap t <Plug>(easymotion-overwin-t2)

" Move to line
map  <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" Gif config
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" These `n` & `N` mappings are options. You do not have to map `n` & `N` to EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
map n <Plug>(easymotion-next)
map N <Plug>(easymotion-prev)

" ============================================================================
" Autocomplete

" Python -------------------------------
let g:python3_host_prog = '/home/lucast/.pyenv/versions/3.6.4/bin/python3'

" Deoplete -----------------------------

" Use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
let g:SuperTabDefaultCompletionType = "<c-n>"
set pumheight=15
set completeopt=menuone,noinsert,noselect
call deoplete#custom#source('ultisnips', 'rank', 1000)
call deoplete#custom#source('ultisnips', 'min_pattern_length', 1)
call deoplete#custom#source('buffer', 'max_menu_width', 90)
call deoplete#custom#source('dictionary', 'min_pattern_length', 1)
call deoplete#custom#source('dictionary', 'rank', 1000)

" Jedi-vim ------------------------------

" Disable autocompletion (using deoplete instead)
let g:jedi#completions_enabled = 0
let deoplete#sources#jedi#show_docstring = 1

" Go -------------------------------------
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

" ============================================================================
" Syntax highlighting and linting

" Syntastic ------------------------------
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_sh_shellcheck_args = "-x"
let g:syntastic_python_flake8_exec = 'python'
let g:syntastic_python_flake8_args = ['-m', 'flake8']
let g:syntastic_filetype_map = {"Dockerfile": "dockerfile"}
let g:syntastic_go_checkers = ['govet', 'errcheck', 'go']

" enable syntax checking
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" AWS ------------------------------
let g:AWSVimValidate = 1
let g:UltiSnipsSnippetDirectories=["UltiSnips", "./bundle/aws-vim/snips"]
let g:AWSSnips = "Alarm Authentication Base64 CreationPolicy FindInMap GetAtt Init Instance InstanceProfile Join LaunchConfiguration LoadBalancer Param Policy RDSIngress Ref Role SGEgress SGIngress ScalingPolicy ScheduledAction SecurityGroup Select Stack Subnet VPC Volume VolumeAttachment WaitCondition WaitConditionHandle asg cft init_command init_file init_group init_user"

" Terraform -------------------------
let g:terraform_align=1
let g:terraform_fold_sections=1
let g:terraform_remap_spacebar=1
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
