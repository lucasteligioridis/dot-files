# Owner
export USER_NAME="lucast"

# PATH
export PATH="/usr/local/share/python:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/lucast/bin"
export EDITOR='vim'
export VISUAL='vim'

# Python virtual environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Colors
export TERM="xterm-256color"
export GREP_COLORS='mt=01;31'

# AWS Variables
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin:~/.local/lib/aws/bin
export EC2_URL=https://ap-southeast-2.ec2.amazonaws.com
export AWS_REGIONS="ap-southeast-2 us-west-2"
source /usr/local/bin/aws_zsh_completer.sh

# export go path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='z'

# disable the correct error...slows us down
unsetopt correct_all
unsetopt correct

# disable stupid zsh globbing
setopt nonomatch

# setup fasd
eval "$(fasd --init auto)"

# bash auto completion and backwards compaitablity for bash_completion
autoload -U compinit && compinit
autoload bashcompinit && bashcompinit
autoload -U history-search-end

# ctrl-backspace delete word
bindkey "\C-h" backward-kill-word

# ctrl-arrow keys
bindkey "^[1;5A" "cd ..\n"
bindkey "^[1;5D" backward-word
bindkey "^[1;5C" forward-word
bindkey "^[1;5B" undo

# source some dodgy guys completion script
source /etc/bash_completion.d/am

# start python virtual environment
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
