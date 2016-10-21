# PATH
export PATH="/Users/lucast/.rvm/gems/ruby-2.3.1/bin:/Users/lucast/.rvm/gems/ruby-2.3.1@global/bin:/Users/lucast/.rvm/rubies/ruby-2.3.1/bin:/Users/lucast/.rbenv/shims:/usr/local/share/python:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/lucast/bin:/Users/lucast/.rvm/bin"
export EDITOR='subl -w'
# export PYTHONPATH=$PYTHONPATH
# export MANPATH="/usr/local/man:$MANPATH"
# Virtual Environment
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects
source /usr/local/bin/virtualenvwrapper.sh
# Owner
export USER_NAME="lucast"
#eval "$(rbenv init -)"
# FileSearch
function f() { find . -iname "*$1*" ${@:2} }
function r() { grep "$1" ${@:2} -R . }
#mkdir and cd
function mkcd() { mkdir -p "$@" && cd "$_"; }
## Aliases ##
alias cppcompile='c++ -std=c++11 -stdlib=libc++'
alias git=hub
# Git pull script
alias gpa='/Users/lucast/Projects/lucas-workdir/scripts/git/git-pull-all.sh'
# Use sublimetext for editing config files
alias zshconfig="subl ~/.zprezto"
alias envconfig="subl ~/Projects/config/env.sh"
# Export Java home variable
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
# AWS Variables
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin
export EC2_URL=https://ap-southeast-2.ec2.amazonaws.com
export LEXER_GEM_ENV=development

# changes hex 0x15 to delete everything to the left of the cursor,
# rather than the whole line
bindkey "^U" backward-kill-line

# binds hex 0x18 0x7f with deleting everything to the left of the cursor
bindkey "^X\\x7f" backward-kill-line

# adds redo
bindkey "^X^_" redo

bindkey "^[f" forward-word
bindkey "^[b" backward-word

bindkey "^[d" kill-word
bindkey "^K" kill-line
