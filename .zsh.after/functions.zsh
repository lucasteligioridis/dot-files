# Clobber entry in known_hosts file
function sshc() { ssh-keygen -f "/Users/lucast/.ssh/known_hosts" -R $1 }

 # Lexer shortcut for accessing popular servers
lexcon () {
  user="lucast"
  PS3="Which Server: "

  opts=("service-consumer-processing-0" "service-consumer-processing-1" "service-consumer-loading-0" "service-consumer-loading-1" "service-consumer-loading-2" "lexer-worker-6" "service-consumer-engage" "service-consumer-yammer" "lexer-api-1" "lexer-api-2" "lexer-dashboard" "lexer-search-1" "lexer-search-2" "lexer-search-3" "lexer-search-4" "lexer-search-5" "lexer-database-1" "lexer-manager" "lexer-website" "beta-services" "beta-staging" "dashboard-database" "service-identity-tasks-worker-3" "service-identity-tasks-worker-4" "service-dashboard-app")
  select opt in "${opts[@]}"
  do
    host=$opt
    break
  done
  ssh -A $user@$host.ec2.camplexer.com
}

# History grep
function hg() { history 0 | grep -i "$1" }
