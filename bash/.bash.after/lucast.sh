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
#export TERM="screen-256color"
export GREP_COLORS='mt=01;31'

# export go path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin

# AWS Variables
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin:~/.local/lib/aws/bin
export EC2_URL=https://ap-southeast-2.ec2.amazonaws.com
export AWS_REGIONS="ap-southeast-2 us-west-2"

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='z'

# setup fasd
eval "$(fasd --init auto)"

source /usr/share/bash-completion/completions/git

# setup pyenv environment paths
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# start python virtual environment
[ command -v pyenv 1>/dev/null 2>&1 ] && eval "$(pyenv init -)"

# autocomplete targets in Makefile
[ -f Makefile ] && complete -W "\$(grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_.-]*$//'\)" make
