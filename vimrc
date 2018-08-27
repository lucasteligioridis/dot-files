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

" nuke all trailing space before a write
au BufWritePre * :%s/\s\+$//e

" set underscore and dash as a word boundary
set iskeyword-=_
set iskeyword-=-

" permanent undo history of files
let s:undoDir = "/home/lucast/.vim/undo"
let &undodir=s:undoDir
set undofile

" turn on backup
set backup
set backupdir=/home/lucast/.vim/tmp/
set dir=/home/lucast/.vim/tmp/

" Shorctuts & key bindings --------------------------------

" put cursor back where it was last time when re-opening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Remap leader key
let mapleader = ","

" move entire pane one line at a time
map <S-Up> <C-y>
map <S-Down> <C-e>
inoremap <S-Up> <C-x><C-y>
inoremap <S-Down> <C-x><C-e>

" Map Ctrl-Backspace to delete the previous word in insert mode.
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
set showtabline=2
set tabpagemax=500
highlight TabLine       ctermfg=green ctermbg=None cterm=None
highlight TabLineFill   ctermfg=white ctermbg=None cterm=None
highlight TabLineSel    ctermfg=202

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
map W :w<CR>

" quit and save shortcuts
map <C-d> :q!<CR>
imap <C-d> <Esc>:q!<CR>
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

" tmux and vim combination
if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"
endif

" fuzzy completion
set rtp+=/.fzf

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

" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_flake8_exec = 'python'
let g:syntastic_python_flake8_args = ['-m', 'flake8']

" Line numbers
set number
set relativenumber

" Neocomplete
" Use deoplete.
let g:deoplete#enable_at_startup = 1
" Enable autocompletion
let g:neocomplete#enable_at_startup = 1
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" AWS
let g:AWSVimValidate = 1
let g:UltiSnipsSnippetDirectories=["UltiSnips", "./bundle/aws-vim/snips"]
let g:AWSSnips = "Alarm Authentication Base64 CreationPolicy FindInMap GetAtt Init Instance InstanceProfile Join LaunchConfiguration LoadBalancer Param Policy RDSIngress Ref Role SGEgress SGIngress ScalingPolicy ScheduledAction SecurityGroup Select Stack Subnet VPC Volume VolumeAttachment WaitCondition WaitConditionHandle asg cft init_command init_file init_group init_user"
au BufRead,BufNewFile *.parameters setlocal filetype=json
au BufRead,BufNewFile *.tags       setlocal filetype=json
au BufRead,BufNewFile *.template   setlocal filetype=yaml

" Terraform
let g:terraform_align=1
let g:terraform_fold_sections=1
let g:terraform_remap_spacebar=1
autocmd FileType terraform setlocal commentstring=//%s
au BufRead,BufNewFile *.tf      setlocal filetype=terraform
au BufRead,BufNewFile *.tfvars  setlocal filetype=terraform
au BufRead,BufNewFile *.tfstate setlocal filetype=javascript

" Docker
au BufRead,BufNewFile Dockerfile.* setlocal filetype=dockerfile

" Ansible
" let g:ansible_attribute_highlight = "ob"
let g:ansible_unindent_after_newline = 1
let g:ansible_extra_keywords_highlight = 1

" Grammar checking
let g:grammarous#default_comments_only_filetypes = {
            \ '*' : 1, 'help' : 0, 'markdown' : 0,
            \ }

" Language-specific formatting
autocmd FileType go   setlocal autoindent noexpandtab tabstop=4 shiftwidth=4
autocmd FileType py   setlocal autoindent expandtab   tabstop=4 shiftwidth=4
autocmd FileType rb   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType sh   setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType zsh  setlocal autoindent expandtab   tabstop=2 shiftwidth=2
autocmd FileType make setlocal autoindent noexpandtab tabstop=2 shiftwidth=2
autocmd FileType yaml setlocal autoindent expandtab   tabstop=2 shiftwidth=2

" omni autocompletions per-language
autocmd FileType python     set omnifunc=python3complete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python     set foldlevel=1
autocmd FileType html       set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css        set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml        set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php        set omnifunc=phpcomplete#CompletePHP
