#!/bin/bash
##
# add some mounting logic here
##
if [ ! -d ${HOME}/Encrypted/lucas ]; then
  read -p "Enter passphrase to unlock disk: " pass
  echo
  printf "%s" "${pass}" | ecryptfs-add-passphrase
  mount.ecryptfs_private Encrypted
  [ $? -eq 0 ] && MOUNTED=1
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

function start_vpn() {
  for vpn in ops red; do
    sudo systemctl is-active --quiet openvpn@${vpn}.service
    if [ $? -ne 0 ]; then
      echo -e "Starting ${vpn} openvpn service..."
      sudo systemctl start openvpn@${vpn}.service
    fi
  done
}
