# Ubuntu-only stuff. Abort if not Ubuntu.
[[ "$(cat /etc/issue 2> /dev/null)" =~ Ubuntu ]] || return 1

# Package management
alias apt-get="sudo apt-fast"
alias update="sudo apt-get -qq update && sudo apt-get upgrade"
alias install="sudo apt-get install"
alias remove="sudo apt-get remove"
alias search="apt-cache search"

alias refresh="source ~/.bashrc"
