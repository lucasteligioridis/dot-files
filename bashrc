# aliases
alias chromium='command chromium --audio-buffer-size=2048'
alias ls='ls --color=auto --group-directories-first'
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias ss="pmset displaysleepnow"
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias v="f -e vim" # quick opening files with vim
alias show_apt_installs='( zcat $( ls -tr /var/log/apt/history.log*.gz ) ; cat /var/log/apt/history.log ) | grep -E "^(Start-Date:|Commandline:)" | grep -v aptdaemon | grep -E "^Commandline:"'
alias rvim='sudo -E vim'

# functions
function sshc() {
  ssh-keygen -f "${HOME}/.ssh/known_hosts" -R ${1}
  ssh -o StrictHostKeyChecking=no ${1}
}

function replace() {
  grep -rsl "${1}" * | tee /dev/stderr | xargs sed -i "s^${1}^${2}^g"
}

### TERRAFORM
function ter() {
  case ${1} in
    "plan")  shift; cmd="terraform init && terraform plan -parallelism=100 ${@}";;
    "apply") shift; cmd="terraform init && terraform apply -auto-approve -parallelism=100 ${@}";;
    "dns")   cmd="grep fqdn terraform.tfstate | awk '{print \$2}' | tr -d '\"' | tr -d ','";;
    "ls")    cmd="terraform show | grep -E '^[a-zA-Z]' | tr -d ':'";;
    "sg")    cmd="grep -E '\"sg-(.*)' terraform.tfstate | awk '{print \$2}' | sort -u | tr -d '\"' | tr -d ','";;
    *)       cmd="terraform ${@}";;
  esac
  echo $cmd
  eval $cmd
}

# git
function git_status() {
  ORANGE='\033[1;31m'
  NC='\033[0m'
  BOLD='\033[1m'
  local PROJECT=$(basename ${PWD})
  local DEFAULT='master'
  local UPSTREAM=${1:-${DEFAULT}}
  local LOCAL=$(git rev-parse master)
  local REMOTE=$(git ls-remote -h -t --quiet | grep master | tr  '\t'  '|' | cut -d "|" -f1)
  local BASE=$(git merge-base master "${UPSTREAM}")
  if [ ${LOCAL} = ${REMOTE} ]; then
      echo -e "${BOLD}${PROJECT}:${NC} Up-to-date, no further action required."
  elif [ ${LOCAL} = ${BASE} ]; then
      echo -e "${BOLD}${ORANGE}${PROJECT}:${NC} Update required, pulling from remote..."
      git ppm
  elif [ ${REMOTE} = ${BASE} ]; then
      echo -e "${BOLD}${PROJECT}:${NC} Push required"
  else
      echo -e "${BOLD}${PROJECT}:${NC} Diverged"
  fi
}

# Download and install latest Terraform
function dlterraform() {
  local version=${1}
  zip="terraform_${version}_linux_amd64.zip"
  url="https://releases.hashicorp.com/terraform/${version}/${zip}"

  if [ ! -z ${version} ] ; then
    (
      cd ${HOME}/bin && \
      wget "${url}" && \
      unzip -o ${zip} && \
      rm ${zip}
    )
  else
    echo "Please input version number you wish to download for Terraform"
  fi
}

# Backup file in same dir
function backup() { cp "${1}"{,.bak}; }

# Sort files by size
function sbs() {
  du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
}

# History grep
function hg() { history 0 | grep -i "${1}"; }

# FileSearch
function f() { find . -iname "*${1}*" ${@:2}; }
function r() { grep "${1}" ${@:2} -R .; }
function sgrep() { grep -rsi ${1} *; }

# mkdir and cd
function mkcd() { mkdir -p "$@" && cd "$_"; }

# Custom
# Owner
export USER_NAME="lucast"

# PATH
export PATH="/usr/local/share/python:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/lucast/bin"
export EDITOR='vim'
export VISUAL='vim'

# Colors
export TERM="xterm-256color"
#export TERM="screen-256color"
export GREP_COLORS='mt=01;31'

# export go path
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# AWS Variables
export EC2_URL=https://ap-southeast-2.ec2.amazonaws.com
export AWS_REGIONS="ap-southeast-2 us-west-2"

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='z'

# setup fasd
eval "$(fasd --init auto)"

# enable some completions
source /usr/share/bash-completion/completions/git

# setup pyenv environment paths
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# start python virtual environment
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# autocomplete targets in Makefile
[ -f Makefile ] && complete -W "\$(grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_.-]*$//'\)" make

# disable software flow control
stty -ixon

# start ssh-agent automatically
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    source "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    source "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# Prompt
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
PROMPT_COMMAND='PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< ${PWD/#$HOME/\~})'
export PS1='\[\033[0;36m\]\[\033[1m\]$PS1X\[\033[0m\]\[\033[1m\]$(_parse_git_status)\[\033[38;5;214m\] ツ \[\033[0m\]'

# enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
