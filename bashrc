#!/bin/bash

# Aliases --------------------------
alias sssh="ssh -q -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t"
alias chromium="command chromium --audio-buffer-size=2048"
alias ls="ls --color=auto --group-directories-first"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias v="f -e vim" # quick opening files with vim
alias show_apt_installs='( zcat $( ls -tr /var/log/apt/history.log*.gz ) ; cat /var/log/apt/history.log ) | grep -E "^(Start-Date:|Commandline:)" | grep -v aptdaemon | grep -E "^Commandline:"'

# Prompt ----------------------------
PROMPT_COMMAND="get_ps1"

# Exports ---------------------------
export EDITOR='vim'
export VISUAL='vim'
export GREP_COLORS='mt=01;31'
export GOROOT=${HOME}/go
export GOPATH=${HOME}/goprojects
export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_COMPLETION_TRIGGER='z'
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:${GOPATH}:${PYENV_ROOT}"
export SHELLCHECK_OPTS="-e SC1090"

# Functions -----------------------
function sudo() {
  if [[ ${1} == "vim" ]]; then
    shift; command sudo -E vim "${@}"
  else
    command sudo "${@}"
  fi
}

function replace() {
  grep -rsl "${1}" -- * | tee /dev/stderr | xargs sed -i "s|${1}|${2}|g"
}

function ter() {
  case ${1} in
    "plan")  shift; terraform init && terraform plan -parallelism=100 "${@}";;
    "apply") shift; terraform init && terraform apply -auto-approve -parallelism=100 "${@}";;
    "dns")   grep fqdn terraform.tfstate | awk '{print $2}' | tr -d '"' | tr -d ',';;
    "ls")    terraform show | grep -E '^[a-zA-Z]' | tr -d ':';;
    "sg")    for i in $(grep -E '"sg-(.*)' terraform.tfstate | awk '{print $2}' | sort -u | tr -d '"' | tr -d ','); do echo "${i}" "$(aws cache "$i")"; done;;
    *)       command terraform "${@}";;
  esac
}

function aws() {
  case ${1} in
    "cache") shift; grep "$1" /tmp/.awscache | awk '{print $2}';;
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
function sfind() { find . -iname "*${1}*" "${@:2}"; }
function rgrep() { grep "${1}" "${@:2}" -R .; }
function sgrep() { grep -rsi "${1}" -- *; }

# check if command exists and run custom startup
function command_init() {
  local app=${1}
  local cmd=${*}

  if command -v "${app}" 1>/dev/null 2>&1; then
    eval "$(${cmd})"
  fi
}

# Parse git branch and status
function get_git() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "${branch}" ]; then
    status=$(git status --porcelain 2> /dev/null)
    grep -qE '^ D'       <<< "${status}" && d="${orange}●" # deleted
    grep -qE '^ A'       <<< "${status}" && a="${yellow}●" # added
    grep -qE '^ M'       <<< "${status}" && m="${red}●"    # modified
    grep -qE '^\?'       <<< "${status}" && u="${blue}●"   # untracked
    grep -qE '^[a-zA-Z]' <<< "${status}" && c="${green}●"  # committed
    echo -e "${bold} (${purple}${branch}${d}${c}${a}${m}${u}${nc}${bold})"
  fi
}

function get_ps1() {
  local nc="\001\e[0m\002"
  local bold="\001\e[1m\002"
  local orange="\001\e[38;5;214m\002"
  local red="\001\e[1;31m\002"
  local yellow="\001\e[1;33m\002"
  local green="\001\e[1;32m\002"
  local blue="\001\e[1;34m\002"
  local teal="\001\e[0;36m\002"
  local purple="\001\e[1;35m\002"

  # shorten path
  PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< "${PWD/#$HOME/\~}")

  # declare prompt
  PS1="${teal}${bold}${PS1X}${nc}$(get_git)${bold}${orange} ツ ${nc}"
}

# Custom init apps ------------------------
command_init fasd --init auto
command_init pyenv init -
command_init hub alias -s

# Misc ------------------------------------
# autocomplete targets in Makefile
[ -f Makefile ] && complete -W "$(grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//')" make

# disable software flow control (dont freeze terminal with C-S)
stty -ixon

# start fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
