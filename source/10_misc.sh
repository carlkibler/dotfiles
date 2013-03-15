# From http://stackoverflow.com/questions/370047/#370255
function path_remove() {
  IFS=:
  # convert it to an array
  t=($PATH)
  unset IFS
  # perform any array operations to remove elements from the array
  t=(${t[@]%%$1})
  IFS=:
  # output the new array
  echo "${t[*]}"
}

alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias path='echo -e ${PATH//:/\\n}'

# for Amazon EC2 instances
alias public_ip="curl http://169.254.169.254/latest/meta-data/public-ipv4"
alias private_ip="curl http://169.254.169.254/latest/meta-data/local-ipv4"

