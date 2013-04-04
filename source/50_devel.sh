export PATH

export WORKON_HOME=$HOME/.envs
export PROJECT_HOME=$HOME/dev
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
source /usr/local/bin/virtualenvwrapper_lazy.sh

alias goenv='cd $VIRTUAL_ENV'

# Git autocompletion.
# TODO: move this to a separate .bash/completion/git or some such.
[ -f ~/git-completion.bash ] && source ~/git-completion.bash;

# Show the current Git branch, if any.
# (This is useful in the shell prompt.)
function git-show-branch {
	branch="$(git symbolic-ref -q HEAD 2>/dev/null)";
	ret=$?;
	case $ret in
		0) echo "(${branch##*/})";;
		1) echo '(no branch)';;
		128) echo -n;;
		*) echo "[unknown git exit code: $ret]";;
	esac;
	return $ret;
}

# Show a unified diff, colourised if possible and paged if necessary.
function udiff {
	if command -v colordiff > /dev/null; then
		colordiff -wU4 "$@" | $PAGER;
		return ${PIPESTATUS[0]};
	elif command -v git > /dev/null && ! [[ " $* " =~ \ /dev/fd ]]; then
		git diff --no-index "$@";
		return $?;
	fi;

	diff -wU4 -x .svn "$@" | $PAGER;
	return ${PIPESTATUS[0]};
}

