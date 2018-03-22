NC="\001\e[0m\002"
BOLD="\001\e[1m\002"
ORANGE="\001\e[38;5;214m\002"
RED="\001\e[1;31m\002"
YELLOW="\001\e[1;33m\002"
GREEN="\001\e[1;32m\002"
BLUE="\001\e[1;34m\002"
PURPLE="\001\e[1;35m\002"

# colorise different git status
parse_git_symbol() {
  echo -e "${1}●${NC}${BOLD}"
}

# lets parse some git magic
parse_git_status() {
  if [ -d .git ]; then
    status=$(git status --porcelain 2> /dev/null)
    branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d '/' -f 3)
    grep -qE '^ D' <<< ${status} && d=$(parse_git_symbol ${ORANGE})
    grep -qE '^ A' <<< ${status} && a=$(parse_git_symbol ${YELLOW})
    grep -qE '^ M' <<< ${status} && m=$(parse_git_symbol ${RED})
    grep -qE '^\?' <<< ${status} && u=$(parse_git_symbol ${BLUE})
    grep -qE '^.'  <<< ${status} && c=$(parse_git_symbol ${GREEN})
    echo -e "${BOLD} (${PURPLE}${branch}${d}${c}${a}${m}${u}${NC}${BOLD})"
  fi
}
PROMPT_COMMAND='PS1X=$(sed "s:\([^/\.]\)[^/]*/:\1/:g" <<< ${PWD/#$HOME/\~})'
export PS1='\[\033[0;36m\]\[\033[1m\]$PS1X\[\033[0m\]\[\033[1m\]$(parse_git_status)\[\033[38;5;214m\] ツ \[\033[0m\]'

# source custom dot files
cd ~/.bash.after
for i in *; do
  source ${i}
done
cd $HOME

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
