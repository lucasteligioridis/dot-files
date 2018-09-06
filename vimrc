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

" Shougo deoplete prereqs
Plug 'Shougo/neco-vim'
Plug 'Shougo/neosnippet.vim'

" Code commenter
Plug 'scrooloose/nerdcommenter'

" File browswer
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Better language packs
Plug 'sheerun/vim-polyglot'

" Tab
Plug 'ervandew/supertab'
Plug 'godlygeek/tabular'

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
Plug 'wincent/command-t', { 'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make' }

" Tmux completer
Plug 'wellle/tmux-complete.vim'

" Async completer
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'

" Linters
Plug 'neomake/neomake'

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

" very basic editor behaviour
set number    " line numbers
set expandtab " tabs -> spaces
set tabstop=2
set wrap

" bash like tab completion
set wildmode=longest,list,full
set wildmenu
set wildignore+=*.pyc,*.o,*.obj,*.svn,*.swp,*.class,*.hg,*.DS_Store,*.min.*,*.git,__pycache__

" nuke all trailing space before a write
au BufWritePre * :%s/\s\+$//e

" put cursor back where it was last time when re-opening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" set dash as a word boundary
set iskeyword-=-

" permanent undo history of files
let s:undoDir = "/home/lucast/.vim/undo"
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
let g:hardtime_default_on = 1

" ============================================================================
" Shorctuts & key bindings

if !has('nvim')
	set ttymouse=xterm2
endif

" Remap leader key
let mapleader = ","

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

function! SuperTab()
    if (strpart(getline('.'),col('.')-2,1)=~'^\W\?$')
        return "\<Tab>"
    else
        return "\<C-n>"
    endif
endfunction
inoremap <Tab> <C-R>=SuperTab()<CR>

" quit/exit shortcuts fat fingers
cmap Q<CR> q<CR>
cmap Q!<CR> q!<CR>
cmap Q1<CR> q!<CR>
cmap q1<CR> q!<CR>
cmap Wq<CR> wq<CR>
map Y y$
map Q :q<CR>

" quit and save shortcuts
"map <C-d> :q!<CR>
"imap <C-d> <Esc>:q!<CR>
map <C-s> :w!<CR>
imap <C-s> <ESC>:w!<CR>
map <Space> i

" Resize panes
map <C-D-left> <C-W><<>
map <C-D-right> :vertical resize -20<CR>

" Command-T
map <C-f> :CommandT<CR>

" Paste below line
nmap <F4> o<ESC>p

" Grammar checker
nmap <F5> :GrammarousCheck<return>

" clear highlight on esc
nnoremap <esc> :noh<return><esc>

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

" Highlight past 80 character
autocmd BufWinEnter * match ErrorMsg /\%>79v.\%<82v/

" ============================================================================
" Interface

" NERDTree ----------------------------------
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
noremap <C-Bslash> :NERDTreeToggle<CR>
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

" ============================================================================
" Autocomplete

" Python -------------------------------
let g:python3_host_prog = '/home/lucast/.pyenv/versions/3.6.4/bin/python3'

" Deoplete -----------------------------

" Use deoplete.
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
set pumheight=15
set completeopt=menuone,noinsert,preview
call deoplete#custom#source('ultisnips', 'rank', 1000)
call deoplete#custom#source('ultisnips', 'min_pattern_length', 1)
call deoplete#custom#source('buffer', 'max_menu_width', 90)
call deoplete#custom#source('dictionary', 'min_pattern_length', 1)
call deoplete#custom#source('dictionary', 'rank', 1000)

" Mappings
" Close popup and delete backward character
inoremap <expr><BS> deoplete#smart_close_popup()."\<BS>"
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" Jedi-vim ------------------------------

" Disable autocompletion (using deoplete instead)
let g:jedi#completions_enabled = 0
let deoplete#sources#jedi#show_docstring = 1
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

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
autocmd FileType go   setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType py   setlocal autoindent expandtab   tabstop=4 shiftwidth=4
autocmd FileType rb   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType sh   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType zsh  setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType make setlocal autoindent noexpandtab tabstop=2 shiftwidth=2
autocmd FileType yaml setlocal autoindent expandtab   tabstop=2 shiftwidth=2

" File type formatting
au BufRead,BufNewFile *.tf         setlocal filetype=terraform
au BufRead,BufNewFile *.tfvars     setlocal filetype=terraform
au BufRead,BufNewFile *.tfstate    setlocal filetype=javascript
au BufRead,BufNewFile *.parameters setlocal filetype=json
au BufRead,BufNewFile *.tags       setlocal filetype=json
au BufRead,BufNewFile *.template   setlocal filetype=yaml
au BufRead,BufNewFile Dockerfile.* setlocal filetype=dockerfile
