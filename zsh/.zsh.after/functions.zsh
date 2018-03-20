# Clobber entry in known_hosts file
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
function hg() { history 0 | grep -i "${1}" }

# FileSearch
function f() { find . -iname "*${1}*" ${@:2} }
function r() { grep "${1}" ${@:2} -R . }
function sgrep() { grep -rsi ${1} * }

# mkdir and cd
function mkcd() { mkdir -p "$@" && cd "$_"; }

#function show_apt_installs () {
#  hist=$(zcat $(ls -tr /var/log/apt/history.log*.gz); cat /var/log/apt/history.log ))
#  echo ${hist} | grep -E "^(Start-Date:|Commandline:)" \
#               | grep -v aptdaemon \
#               | grep -E "^Commandline:"
#}

### TMUX
function tab_colour() {
  echo -ne "\033]6;1;bg;red;brightness;$1\a"
  echo -ne "\033]6;1;bg;green;brightness;$2\a"
  echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}
function tab_reset() {
  echo -ne "\033]6;1;bg;*;default\a"
}

# Set the tab colour to yellow (or green if tmux)
if [ $TMUX ]; then
  tab_colour 110 221 76
else
  tab_colour 255 200 46
fi
