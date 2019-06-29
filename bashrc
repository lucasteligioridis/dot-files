#!/bin/bash

# Defaults from /etc/skel/.bashrc ------------

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth:erasedups:ignorespace
HISTSIZE=100000
HISTFILESIZE=1000000
HISTTIMEFORMAT='%F %T ' # use standard ISO time format

# determine OS to run custom commands
case "${OSTYPE}" in
  linux*)
    os_open="xdg-open"
    c_path="${HOME}/.config/chromium"
  ;;
  darwin*)
    os_open="open"
    c_path="${HOME}/Library/Application Support/Google/Chrome"
  ;;
esac

# https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
shopt -s histappend   # append to the history file, don't overwrite it
shopt -s checkwinsize # update the values of LINES and COLUMNS
shopt -s cdspell      # minor errors in the spelling of a directory component in a cd command will be corrected.
shopt -s dirspell     # minor errors in the spelling of a directory during tab-completion
shopt -s autocd       # a command name that is the name of a directory is executed as if it were the argument to the cd command
shopt -s cmdhist      # save all lines of a multiple-line command in the same history entry
shopt -u execfail     # exec process should kill the shell when it exits
shopt -s globstar     # turn on recursive globbing

# Aliases --------------------------
alias sssh="ssh -q -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t"
alias chromium="command chromium --audio-buffer-size=2048"
alias ls="ls --color=auto --group-directories-first"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias v="vf" # quick opening files with vim
alias show_apt_installs='( zcat $( ls -tr /var/log/apt/history.log*.gz ) ; cat /var/log/apt/history.log ) | grep -E "^(Start-Date:|Commandline:)" | grep -v aptdaemon | grep -E "^Commandline:"'
alias :q="exit"

# Prompt ----------------------------
PROMPT_COMMAND="get_ps1"

# Exports ---------------------------
export EDITOR="vim"
export VISUAL="${EDITOR}"
export GREP_COLORS="mt=01;31"
export GOROOT="${HOME}/go"
export GOPATH="${HOME}/goprojects"
export FZF_COMPLETION_TRIGGER="z"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --no-messages -g "!{.git,*.swp,**/.terraform}/*" 2> /dev/null'
export FZF_DEFAULT_OPTS="--bind J:down,K:up --reverse --ansi --multi"
export PYENV_ROOT="${HOME}/.pyenv"
export YARN_PATH="${HOME}/.yarn/bin:${HOME}/.config/yarn/global/node_modules/.bin"
export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin:${GOPATH}:${GOPATH}/bin:${GOROOT}/bin:${PYENV_ROOT}/bin:${YARN_PATH}"
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
tm() {
  local name=${1}
  [[ -n "${TMUX}" ]] && change="switch-client" || change="attach-session"
  if [ "${name}" ]; then
    tmux "${change}" -t "${name}" 2>/dev/null || (tmux new-session -d -s "${name}" && tmux ${change} -t "${name}"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) && tmux ${change} -t "${session}" || echo "No sessions found."
}

# search current directory for all files recursively and open with vim
fvim() {
  local IFS=$'\n'
  local files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "${files[@]}" ]] && ${EDITOR} "${files[@]}"
}

# vim with fasd and fzf
vf() {
  local file
  file="$(fasd -Rfl "$1" | fzf --height 40% -1 -0 --no-sort +m)"
  [[ -n "${file}" ]] && ${EDITOR} "${file}"
}

# search for string in all files recursively in current directory and open with vim
vfind() {
  if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
  printf -v search "%q" "$*"
  exclude=".config,.git,.lock,**/.terraform"
  rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --no-messages --color "always" -g "!{'${exclude}'}/*"'
  files=($(eval "${rg_command}" "${search}" | fzf --ansi --multi --reverse | awk -F ':' '{print $1":"$2":"$3}'))
  [[ -n "${files[@]}" ]] && ${EDITOR} -p "${files[@]}"
}

# diff git commit
flog() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | fzf | awk '{print $1}')
  echo "${hash}" | xclip
  git showtool "${hash}"
}

# search git commits and find hash
gc() {
  hash=$(git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | fzf | awk '{print $1}')
  [[ -n "${hash}" ]] && gopen "${hash}"
}

# open git commit in browser
gopen() {
  local hash=${1}
  # github.com:example/project
  url=$(git config --local remote.origin.url | sed 's/@git//' | sed 's/\.git//')
  domain=${url%%:*} # github.com
  project=${url#*:} # example/project
  username=${project%%/*} # example
  repo=${project#*/} # project
  commit="https://${domain}/${username}/${repo}/commit/${hash}"
  "${os_open}" "${commit}" >/dev/null 2>/dev/null
}

# search latest 30 branches and checkout
branch() {
  local branches branch
  branches=$(git branch --all) &&
  branch=$(echo "${branches}" | fzf-tmux -d $(( 2 + $(wc -l <<< "${branches}") )) +m) &&
  git checkout "$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# search chrome/chromium history and launch in browser
ch() {
  local cols sep c_history
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  c_history="${c_path}/Default/History"
  cp -f "${c_history}" /tmp/h
  sqlite3 -separator ${sep} /tmp/h \
    "select substr(title, 1, ${cols}), url
     from urls order by last_visit_time desc" |
  awk -F ${sep} '{printf "%-'${cols}'s  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi --query="!localhost " | sed 's#.*\(https*://\)#\1#' | xargs "${os_open}" > /dev/null 2> /dev/null
}

fuzzpass() {
  local arg=$1
  local item
  item=$(1pass | fzf-tmux)
  [[ ! -z "${arg}" ]] || arg="password"
  [[ ! -z "${item}" ]] && 1pass "${item}" "${arg}"
}

sudo() {
  if [[ ${1} == "vim" ]]; then
    shift; command sudo -E vim "${@}"
  else
    command sudo "${@}"
  fi
}

# replace all matching strings
replace() {
  local search=${1}
  local replace=${2}
  grep -rsl "${search}" -- * | tee /dev/stderr | xargs sed -i "s|${search}|${replace}|g"
}

# sort files by size
sbs() {
  du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';
}

# file search
sfind() { find . -iname "*${1}*" "${@:2}"; }
rgrep() { grep "${1}" "${@:2}" -R .; }
sgrep() { grep -rsin "${1}" -- *; }

# check if command exists and run custom startup
command_init() {
  local app=${1}
  local cmd=${*}
  if command -v "${app}" 1>/dev/null 2>&1; then
    eval "$(${cmd})"
  fi
}

# parse git branch and status
get_git() {
  branch=$(_branch_name) || return
  status=$(git status --porcelain 2> /dev/null)
  grep -qE '^ D'       <<< "${status}" && d="${orange}●" # deleted
  grep -qE '^ A'       <<< "${status}" && a="${yellow}●" # added
  grep -qE '^ M'       <<< "${status}" && m="${red}●"    # modified
  grep -qE '^\?'       <<< "${status}" && u="${blue}●"   # untracked
  grep -qE '^[a-zA-Z]' <<< "${status}" && c="${green}●"  # committed
  echo -e "${bold} (${purple}${branch}${d}${c}${a}${m}${u}${nc}${bold})"
}

get_ps1() {
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
  PS1="${teal}${bold}${PS1X}${nc}$(get_git)${bold}${orange} λ ${nc}"
}

# helpers
_fzf_down() {
  fzf --height 50% "$@" --border
}

_branch_name() {
  git rev-parse --abbrev-ref HEAD 2> /dev/null
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
