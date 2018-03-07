#!/bin/bash
# mount encrypted disk 
if [ ! -d ${HOME}/Encrypted/lucas ]; then
  read -s "pass?Enter passphrase to unlock disk: "
  echo
  printf "%s" "${pass}" | ecryptfs-add-passphrase
  mount.ecryptfs_private Encrypted
fi

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
if [ -f "${SSH_ENV}" ] && [ -n ${MOUNTED} ]; then
    source "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# start our vpns
function start_vpn() {
  sudo ${HOME}/Encrypted/lucas/scripts/vpn/vpn.sh ${1}
}

function ping_gw() { ping -q -w 1 -c 1 $(ip r | grep default | cut -d ' ' -f 3) > /dev/null && return 0 || return 1 }
if [ ping_gw ]; then
  red=$(ps -ef | grep -Eo "open(.*)" | grep red | head -n 1)
  ops=$(ps -ef | grep -Eo "open(.*)" | grep ops | head -n 1)
  if [ -z ${ops} ]; then
    echo -e "Starting operations vpn...\n"
    start_vpn ops
    echo -e "\n"
  fi
  if [ -z ${red} ]; then
    echo -e "Starting redzone vpn...\n"
    start_vpn red
    echo -e "\n"
  fi
fi
