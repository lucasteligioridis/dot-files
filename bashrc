#!/bin/bash

# Defaults from /etc/skel/.bashrc ------------

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth:erasedups:ignorespace
HISTSIZE=100000
HISTFILESIZE=1000000

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
shopt -s histappend   # append to the history file, don't overwrite it
shopt -s checkwinsize # update the values of LINES and COLUMNS
shopt -s cdspell      # minor errors in the spelling of a directory component in a cd command will be corrected.
shopt -s cmdhist      # save all lines of a multiple-line command in the same history entry
shopt -u execfail     # exec process should kill the shell when it exits

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
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,*.swp,dist,.terraform}/*" 2> /dev/null'
export FZF_DEFAULT_OPTS="--bind J:down,K:up --reverse --ansi --multi"
export PYENV_ROOT="${HOME}/.pyenv"
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:${GOPATH}:${PYENV_ROOT}/bin"
export SHELLCHECK_OPTS="-e SC1090" # ignore https://github.com/koalaman/shellcheck/wiki/SC1090
export OKTA_USERNAME="lucas.teligioridis"

# color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Binds ---------------------------
bind -x '"\C-f": fvim'

# Functions -----------------------
# search all available tmux sessions
function tm() {
  [[ -n "${TMUX}" ]] && change="switch-client" || change="attach-session"
  if [ "${1}" ]; then
    tmux "${change}" -t "${1}" 2>/dev/null || (tmux new-session -d -s "${1}" && tmux ${change} -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux ${change} -t "${session}" || echo "No sessions found."
}

# search current directory for all files recursively and open with vim
function fvim() {
  local IFS=$'\n'
  local files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "${files[@]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

# search for string in all files recursively in current directory and open with vim
function ffind() {
  if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
  printf -v search "%q" "$*"
  exclude=".config,.git,node_modules,vendor,build,yarn.lock,*.sty,*.bst,*.coffee,dist,.terraform"
  rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "!{'${exclude}'}/*"'
  files=($(eval "${rg_command}" "${search}" | fzf --ansi --multi --reverse | awk -F ':' '{print $1":"$2":"$3}'))
  [[ -n "${files[@]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

# diff git commit
function flog() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |  fzf | awk '{print $1}')
  echo "${hash}" | xclip
  git showtool "${hash}"
}

# search git commits and find hash
function gc() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |  fzf | awk '{print $1}')
  gopen "${hash}"
}

# open git commit in browser
function gopen() {
  local hash=${1}
  project=$(git config --local remote.origin.url)
  url=$(dirname "${project}")
  repo=$(basename "${project%.*}")
  if [[ "${url}" == *"github"* ]]; then
    commit="${url}/${repo}/commit/${hash}"
  elif [[ "${url}" == *"bitbucket"* ]]; then
    commit="${url/scm/projects}/repos/${repo}/commits/${hash}"
  fi
  xdg-open "${commit}" >/dev/null 2>/dev/null
}

# search latest 30 branches and checkout
function branch() {
  local branches branch
  branches=$(git for-each-ref --count=30 --format="%(refname:short)")
  branch=$(echo "${branches}" | fzf-tmux -d $(( 2 + $(wc -l <<< "${branches}") )) +m)
  git checkout "$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# search chromium history and launch in browser
function ch() {
  local cols sep google_history
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  google_history="${HOME}/.config/chromium/Default/History"
  cp -f "${google_history}" /tmp/h
  sqlite3 -separator ${sep} /tmp/h \
    "select substr(title, 1, ${cols}), url
     from urls order by last_visit_time desc" |
  awk -F ${sep} '{printf "%-'${cols}'s  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi --query="!localhost " | sed 's#.*\(https*://\)#\1#' | xargs xdg-open > /dev/null 2> /dev/null
}

function sudo() {
  if [[ ${1} == "vim" ]]; then
    shift; command sudo -E vim "${@}"
  else
    command sudo "${@}"
  fi
}

# replace all matching strings
function replace() {
  local search=${1}
  local replace=${2}
  grep -rsl "${search}" -- * | tee /dev/stderr | xargs sed -i "s|${search}|${replace}|g"
}

# sort files by size
function sbs() {
  du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
}

# file search
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

# parse git branch and status
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
