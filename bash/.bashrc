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

# source custom dot files
for i in ~/.bash.after/*; do
  source ${i};
done

# enable fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
