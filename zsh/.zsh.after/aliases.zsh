#alias git=hub
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'" 
alias ss="pmset displaysleepnow"
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias v="f -e vim" # quick opening files with vim
alias show_apt_installs='( zcat $( ls -tr /var/log/apt/history.log*.gz ) ; cat /var/log/apt/history.log ) | grep -E "^(Start-Date:|Commandline:)" | grep -v aptdaemon | grep -E "^Commandline:"'
