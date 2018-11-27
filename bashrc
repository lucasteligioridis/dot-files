#!/bin/bash

# Defaults from /etc/skel/.bashrc ------------

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=100000

# append to the history file, don't overwrite it
shopt -s histappend

# update the values of LINES and COLUMNS
shopt -s checkwinsize

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
export EDITOR="vim"
export VISUAL="${EDITOR}"
export GREP_COLORS="mt=01;31"
export GOROOT="${HOME}/go"
export GOPATH="${HOME}/goprojects"
export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_COMPLETION_TRIGGER="z"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules,*.swp,dist,*.coffee}/*" 2> /dev/null'
export FZF_DEFAULT_OPTS="--bind J:down,K:up --reverse --ansi --multi"
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:${GOPATH}:${PYENV_ROOT}/bin"
export SHELLCHECK_OPTS="-e SC1090" # ignore https://github.com/koalaman/shellcheck/wiki/SC1090
export OKTA_USERNAME="lucas.teligioridis"

# Binds ---------------------------
bind -x '"\C-f": fvim'

# Functions -----------------------
function tm() {
  [[ -n "${TMUX}" ]] && change="switch-client" || change="attach-session"
  if [ "${1}" ]; then
    tmux "${change}" -t "${1}" 2>/dev/null || (tmux new-session -d -s "${1}" && tmux ${change} -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux ${change} -t "${session}" || echo "No sessions found."
}

function fvim() {
  local IFS=$'\n'
  local files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "${files[@]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

function ffind() {
  if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
  printf -v search "%q" "$*"
  include="ts,yml,js,json,php,md,styl,pug,jade,html,config,py,cpp,c,go,hs,rb,conf,fa,lst,tf"
  exclude=".config,.git,node_modules,vendor,build,yarn.lock,*.sty,*.bst,*.coffee,dist,.terraform"
  rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "*.{'$include'}" -g "!{'$exclude'}/*"'
  files=$(eval "${rg_command}" "${search}" | fzf --ansi --multi --reverse | awk -F ':' '{print $1":"$2":"$3}')
  [[ -n "${files[@]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

function flog() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |  fzf | awk '{print $1}')
  echo "${hash}" | xclip
  git show "${hash}"
}

function gc() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |  fzf | awk '{print $1}')
  gopen "${hash}"
}

function gopen() {
  project=$(git config --local remote.origin.url | sed s/git@github.com\\:// | sed s/\.git//)
  url="http://github.com/${project}/commit/${1}"
  xdg-open "${url}"
}

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
    "sg")    for i in $(grep -E '"sg-(.*)' terraform.tfstate | awk '{print $2}' | sort -u | tr -d '"' | tr -d ','); do echo "${i}"; done;;
    *)       command terraform "${@}";;
  esac
}

# Sort files by size
function sbs() {
  du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
}

# FileSearch
function sfind() { find . -iname "*${1}*" "${@:2}"; }
function rgrep() { grep "${1}" "${@:2}" -R .; }
function sgrep() { grep -rsin "${1}" -- *; }

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

# custom bash_completions
if [ -d ~/.bash_completion.d ]; then
  for file in ~/.bash_completion.d/*; do
    source "${file}"
  done
fi
