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
alias :q="exit"
alias 1p="ykman oath code 1p"

# Prompt ----------------------------
PROMPT_COMMAND="get_ps1"

# Exports ---------------------------
export EDITOR="vim"
export VISUAL="${EDITOR}"
export GREP_COLORS="mt=01;31"
export GOPATH="${HOME}/goprojects"
export FZF_COMPLETION_TRIGGER="z"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --no-messages -g "!{.git,*.swp,**/.terraform}/*" 2> /dev/null'
export FZF_DEFAULT_OPTS="--bind J:down,K:up --reverse --ansi --multi"
export PYENV_ROOT="${HOME}/.pyenv"
export YARN_PATH="${HOME}/.yarn/bin:${HOME}/.config/yarn/global/node_modules/.bin"
export PATH="/usr/local/bin:${PATH}:${HOME}/bin:${HOME}/.local/bin:${GOPATH}:${GOPATH}/bin:${GOROOT}/bin:${PYENV_ROOT}/bin:${YARN_PATH}"
export SHELLCHECK_OPTS="-e SC1090" # ignore https://github.com/koalaman/shellcheck/wiki/SC1090

# color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Colors --------------------------
nc='\[\033[0m\]'
bold='\[\033[1m\]'
dim='\[\033[90m\]'
bright='\[\033[1;37m\]'
orange='\[\033[38;5;214m\]'
red='\[\033[31m\]'
rred='\[\033[38;5;196m\]'
yellow='\[\033[1;33m\]'
green='\[\033[1;32m\]'
blue='\[\033[1;34m\]'
teal='\[\033[38;5;14m\]'
white='\[\033[38;5;231m\]'
purple='\[\033[1;35m\]'

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

fs() {
	local -r fmt='#{session_id}:|#S|(#{session_attached} attached)'
	{ tmux display-message -p -F "${fmt}" && tmux list-sessions -F "${fmt}"; } \
		| awk '!seen[$1]++' \
		| column -t -s "|" \
		| fzf -q "$" --reverse --prompt "switch session: " -1 \
		| cut -d ":" -f1 \
		| xargs tmux switch-client -t
}

# search current directory for all files recursively and open with vim
fvim() {
  local IFS=$'\n'
  local files
  mapfile -t files < <(fzf-tmux --query="${1}" --multi --select-1 --exit-0)
  [[ -n "${files[*]}" ]] && ${EDITOR} "${files[@]}"
}

# vim with fasd and fzf
vf() {
  local file
  file="$(fasd -Rfl "$1" | fzf --height 40% -1 -0 --no-sort +m)"
  [[ -n "${file}" ]] && ${EDITOR} "${file}"
}

# search for string in all files recursively in current directory and open with vim
vfind() {
  local files
  if [ "$#" -lt 1 ]; then echo "Supply string to search for!"; return 1; fi
  printf -v search "%q" "$*"
  exclude=".config,.git,.lock,**/.terraform"
  rg_command='rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --no-messages --color "always" -g "!{'${exclude}'}/*"'
  mapfile -t files < <(eval "${rg_command}" "${search}" | fzf --ansi --multi --reverse | awk -F ':' '{print $1":"$2":"$3}')
  [[ -n "${files[*]}" ]] && ${EDITOR} -p "${files[@]}"
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

# search commits and show diff
gh() {
  _branch_name > /dev/null || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  _fzf_down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
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
  local item result
  item=$(1pass)
  result=$(echo "${item}" | fzf)
  [[ -n "${arg}" ]] || arg="password"
  [[ -n "${item}" ]] && 1pass "${result}" "${arg}"
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

kube_prompt() {
  local source=${0}
  local context env

  # grab context from config, this is way fast to fetch
  context=$(grep "current-context:" ${HOME}/.kube/config | sed "s/current-context: //") || return

  # change message if running for tmux status
  if [ "${source}" == "tmux" ]; then
    sub_msg=""
    red="#[fg=red]"
    green="#[fg=green]"
    blue="#[fg=blue]"
    nc="#[fg=default]"
  else
    sub_msg="${dim} in "
  fi

  kube_symbol="${blue}ﴱ${nc}"

  # change color if in production
  if [[ "${context}" == *"prod"* ]]; then
    msg="${sub_msg}${kube_symbol} ${red} ${red}${context}${nc}"
  else
    msg="${sub_msg}${kube_symbol} ${green}${context}${nc}"
  fi

  echo -e "${msg}"
}

get_ps1() {
  # shorten path
  # shellcheck disable=SC2001
  PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< "${PWD/#$HOME/\~}")

  # declare prompt
  PS1="${teal}${bold}${PS1X}${nc}$(_git_prompt)$(kube_prompt)${bold}\n${orange}λ ${nc}"
}

# Helpers -----------------------
_fzf_down() {
  fzf --height 50% "$@" --border
}

_branch_name() {
  git rev-parse --abbrev-ref HEAD 2> /dev/null
}

# Git Prompt -----------------------
_git_prompt() {
  if _git_status; then
    # set default prompt
    git_status="${bold} ${bright}on ${purple} ${git_branch}${git_hash}${bold}${purple} [${nc}"

    # ahead/behind from origin
    if [[ "${git_behind}" -ne 0 || "${git_ahead}" -ne 0 ]]; then
      [ "${git_behind}" -ne 0 ] && git_status="${git_status}${teal}↓${git_behind}"
      [ "${git_ahead}" -ne 0 ] && git_status="${git_status}${teal}↑${git_ahead}"

      # set delimeter between ahead/behind and raw stats
      git_status="${git_status}${purple}|"
    fi

    # display raw stats
    [ "${git_staged}" -ne 0 ] && git_status="${git_status}${orange}●${git_staged}"
    [ "${git_conflicts}" -ne 0 ] && git_status="${git_status}${blue}✘${git_conflicts}"
    [ "${git_changed}" -ne 0 ] && git_status="${git_status}${green}✚${git_changed}"
    [ "${git_deleted}" -ne 0 ] && git_status="${git_status}${red}-${git_deleted}"
    [ "${git_untracked}" -ne 0 ] && git_status="${git_status}${nc}?${git_untracked}"

    # check if clean
    if [[ "${git_staged}" -eq 0 && "${git_conflicts}" -eq 0 && "${git_changed}" -eq 0 && "${git_untracked}" -eq 0 && "${git_deleted}" -eq 0 ]]; then
      git_status="${git_status}${green}✔"
    fi

    git_status="${git_status}${purple}]${nc}"
    echo -e "${git_status}"
  fi
}

_git_parse_branch() {
  local branch_line=$1
  IFS="^" read -ra branch_fields <<< "${branch_line}"

  # determine type of branch
  git_branch="${branch_fields[0]}"
  hash="HEAD"
  if [[ "${branch_name}" == *"Initial commit on"* ]]; then
    git_branch="${fields[3]}"
  elif [[ "${branch_name}" == *"No commits yet on"* ]]; then
    git_branch="${fields[4]}"
  elif [[ "${branch_name}" == *"no branch"* ]]; then
    git_branch=$(_git_tag_hash)
  else
    IFS="[,]" read -ra remote_fields <<< "${branch_fields[@]}"
    # check if branch is ahead/behind from origin
    for remote_field in "${remote_fields[@]}"; do
      if grep -qE 'ahead' <<< "${remote_field}"; then
        ahead="${remote_field:6}"
      elif grep -qE 'behind' <<< "${div}"; then
        behind="${remote_field:7}"
      fi
    done
    git_hash=$(_git_tag_hash)
  fi
}

_git_parse_status() {
  local git_status=$1
  while IFS='' read -r line || [[ -n "${line}" ]]; do
    status="${line:0:2}"
    while [[ -n ${status} ]]; do
      case "${status}" in
        # two fixed character matches, loop finished
        "##") git_branch_line="${line/\.\.\./^}"; git_branch_line="${git_branch_line/\#\# }"; break ;;
        "??") ((git_untracked++)); break ;;
        ?U) ((git_conflicts++)); break;;
        ?D) ((git_deleted++)); break;;
        # two character matches, first loop
        ?M) ((git_changed++)) ;;
        ?D) ((git_changed++)) ;;
        ? ) ;;
        # single character matches, second loop
        U) ((git_conflicts++)) ;;
        \ ) ;;
        *) ((git_staged++)) ;;
      esac
      status="${status:0:$((${#status}-1))}"
    done
  done <<< "${git_status}"
}

_git_tag_hash() {
  local hash tag
  tag=$(git describe --tags --exact-match 2> /dev/null)
  hash=$(git rev-parse --short HEAD 2> /dev/null)
  if [[ -n "${hash}" ]]; then
    echo "  ${hash}"
  elif [[ -n "${tag}" ]]; then
    echo " 炙${tag}"
  else
    return
  fi
}

_git_status() {
  # grab raw status from git
  git_status=$(git status --porcelain --branch 2> /dev/null) || return

  # set default variables
  git_branch=""
  git_hash=""
  git_untracked=0
  git_staged=0
  git_changed=0
  git_conflicts=0
  git_deleted=0
  git_ahead=0
  git_behind=0

  # parse the git status
  _git_parse_status "${git_status}"

  # create git branch
  _git_parse_branch "${git_branch_line}"
}


# Custom init apps ------------------------
command_init fasd --init auto
command_init pyenv init -
command_init rbenv init -
command_init nodenv init -
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
