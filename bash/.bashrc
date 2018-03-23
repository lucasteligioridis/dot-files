NC="\001\e[0m\002"
BOLD="\001\e[1m\002"
ORANGE="\001\e[38;5;214m\002"
RED="\001\e[1;31m\002"
YELLOW="\001\e[1;33m\002"
GREEN="\001\e[1;32m\002"
BLUE="\001\e[1;34m\002"
PURPLE="\001\e[1;35m\002"

# check if in git directory
_in_git() {
  local dir=${PWD}
  until [[ ${dir} == / ]]; do
    [[ -d "${dir}/.git" ]] && return 0
    dir=$(dirname "${dir}")
  done
  return 1
}

# colorise different git status
_parse_git_symbol() {
  echo -e "${1}●${NC}${BOLD}"
}

# lets parse some git magic
_parse_git_status() {
  _in_git || return 1
  status=$(git status --porcelain 2> /dev/null)
  branch=$(git symbolic-ref --short HEAD)
  grep -qE '^ D'       <<< ${status} && d=$(_parse_git_symbol ${ORANGE}) # deleted
  grep -qE '^ A'       <<< ${status} && a=$(_parse_git_symbol ${YELLOW}) # added
  grep -qE '^ M'       <<< ${status} && m=$(_parse_git_symbol ${RED})    # modified
  grep -qE '^\?'       <<< ${status} && u=$(_parse_git_symbol ${BLUE})   # untracked
  grep -qE '^[a-zA-Z]' <<< ${status} && c=$(_parse_git_symbol ${GREEN})  # committed
  echo -e "${BOLD} (${PURPLE}${branch}${d}${c}${a}${m}${u}${NC}${BOLD})"
}
PROMPT_COMMAND='PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< ${PWD/#$HOME/\~})'
export PS1='\[\033[0;36m\]\[\033[1m\]$PS1X\[\033[0m\]\[\033[1m\]$(_parse_git_status)\[\033[38;5;214m\] ツ \[\033[0m\]'

# source custom dot files
for i in ~/.bash.after/*; do
  source ${i};
done

# enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
