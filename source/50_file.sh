# Files will be created with these permissions:
# files 644 -rw-r--r-- (666 minus 022)
# dirs  755 drwxr-xr-x (777 minus 022)
umask 022

# Always use color output for `ls`
if [[ "$OSTYPE" =~ ^darwin ]]; then
  alias ls="command ls -GF"
else
  alias ls="command ls -F --color"
  export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
fi

# Directory listing
if [[ "$(type -P tree)" ]]; then
  alias ll='tree --dirsfirst -aLpughDFiC 1'
  alias lsd='ll -dF'
else
  alias ll='ls -alF'
  alias lsd='CLICOLOR_FORCE=1 ll | grep --color=never "^d"'
fi

# ls variants
alias lsa='ls -lsaF'
alias ltr='ls -lsatrF'

# Easier navigation: .., ..., -
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .4='cd ../../../..'

alias -- -='cd -'

# File size
alias fs="stat -f '%z bytes'"
alias df="df -h"

# Recursively delete `.DS_Store` files
alias dsstore="find . -name '*.DS_Store' -type f -ls -delete"

# Aliasing eachdir like this allows you to use aliases/functions as commands.
alias eachdir=". eachdir"

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

# Fast directory switching
_Z_NO_PROMPT_COMMAND=1
_Z_DATA=~/.dotfiles/caches/.z
. ~/.dotfiles/libs/z/z.sh


# Make less the default pager, and specify some useful defaults.
less_options=(
# If the entire text fits on one screen, just show it and quit. (Be more
# like "cat" and less like "more".)
--quit-if-one-screen

# Do not clear the screen first.
--no-init

# Like "smartcase" in Vim: ignore case unless the search pattern is mixed.
--ignore-case

# Do not automatically wrap long lines.
--chop-long-lines

# Allow ANSI colour escapes, but no other escapes.
--RAW-CONTROL-CHARS

# Do not ring the bell when trying to scroll past the end of the buffer.
--quiet

# Do not complain when we are on a dumb terminal.
--dumb
);
export LESS="${less_options[*]}";
unset less_options;
export PAGER='less';

# Make "less" transparently unpack archives etc.
if [ -x /usr/bin/lesspipe ]; then
  eval $(/usr/bin/lesspipe);
elif command -v lesspipe.sh > /dev/null; then
  # MacPorts recommended "/opt/local/bin/lesspipe.sh", but this is more
  # portable for people that have it in another directory in their $PATH.
  eval $(lesspipe.sh);
fi;

