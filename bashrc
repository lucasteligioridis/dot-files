# Aliases --------------------------
alias sssh="ssh -q -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t"
alias chromium="command chromium --audio-buffer-size=2048"
alias ls="ls --color=auto --group-directories-first"
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias ss="pmset displaysleepnow"
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias v="f -e vim" # quick opening files with vim
alias show_apt_installs='( zcat $( ls -tr /var/log/apt/history.log*.gz ) ; cat /var/log/apt/history.log ) | grep -E "^(Start-Date:|Commandline:)" | grep -v aptdaemon | grep -E "^Commandline:"'
alias rvim='sudo -E vim'

# Functions -----------------------
function replace() {
  grep -rsl "${1}" * | tee /dev/stderr | xargs sed -i "s|${1}|${2}|g"
}

function ter() {
  case ${1} in
    "plan")  shift; terraform init && terraform plan -parallelism=100 ${@};;
    "apply") shift; terraform init && terraform apply -auto-approve -parallelism=100 ${@};;
    "dns")   grep fqdn terraform.tfstate | awk '{print $2}' | tr -d '"' | tr -d ',';;
    "ls")    terraform show | grep -E '^[a-zA-Z]' | tr -d ':';;
    "sg")    for i in $(grep -E '"sg-(.*)' terraform.tfstate | awk '{print $2}' | sort -u | tr -d '"' | tr -d ','); do echo $i $(aws cache $i); done;;
    *)       command terraform "${@}";;
  esac
}

function aws() {
  case ${1} in
    "cache") shift; grep $1 /tmp/.awscache | awk '{print $2}';;
    *) command aws "${@}";;
  esac
}

# Backup file in same dir
function bak() { cp "${1}"{,.bak}; }

# Sort files by size
function sbs() {
  du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
}

# FileSearch
function sfind() { find . -iname "*${1}*" ${@:2}; }
function rgrep() { grep "${1}" ${@:2} -R .; }
function sgrep() { grep -rsi ${1} *; }

# Exports --------------------------------
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin"
export EDITOR='vim'
export VISUAL='vim'
export GREP_COLORS='mt=01;31'
export GOROOT=${HOME}/go
export GOPATH=${HOME}/goprojects
export PATH=${PATH}:${GOROOT}/bin:${GOPATH}
export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_COMPLETION_TRIGGER='z'
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"

# setup fasd
eval "$(fasd --init auto)"

# enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# start python virtual environment
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# autocomplete targets in Makefile
[ -f Makefile ] && complete -W "$(grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//')" make

# disable software flow control (dont freeze terminal)
stty -ixon

# Prompt ----------------------------
NC="\001\e[0m\002"
BOLD="\001\e[1m\002"
ORANGE="\001\e[38;5;214m\002"
RED="\001\e[1;31m\002"
YELLOW="\001\e[1;33m\002"
GREEN="\001\e[1;32m\002"
BLUE="\001\e[1;34m\002"
PURPLE="\001\e[1;35m\002"

# lets parse some git magic
_parse_git_status() {
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "${branch}" ]; then
    status=$(git status --porcelain 2> /dev/null)
    grep -qE '^ D'       <<< ${status} && d="${ORANGE}●" # deleted
    grep -qE '^ A'       <<< ${status} && a="${YELLOW}●" # added
    grep -qE '^ M'       <<< ${status} && m="${RED}●"    # modified
    grep -qE '^\?'       <<< ${status} && u="${BLUE}●"   # untracked
    grep -qE '^[a-zA-Z]' <<< ${status} && c="${GREEN}●"  # committed
    echo -e "${BOLD} (${PURPLE}${branch}${d}${c}${a}${m}${u}${NC}${BOLD})"
  fi
}

# short prompt path
PROMPT_COMMAND='PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< ${PWD/#$HOME/\~})'
export PS1='\[\033[0;36m\]\[\033[1m\]$PS1X\[\033[0m\]\[\033[1m\]$(_parse_git_status)\[\033[38;5;214m\] ツ \[\033[0m\]'
