# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion;

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export GREP_OPTIONS='--color=auto'

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# Set the terminal's title bar.
function titlebar() {
  echo -n $'\e]0;'"$*"$'\a'
}

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp stfp
fi

export EDITOR=vim
export PAGER=less

# Utilities
# -----------------------------------------------------------------------------
# Open the manual page for the last command you executed.
function lman {
	set -- $(fc -nl -1);
	while [ $# -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do
		shift;
	done;
	cmd="$(basename "$1")";
	man "$cmd" || help "$cmd";
}

# Clipboard access. I created these aliases to have the same command on
# Cygwin, Linux and OS X.
if command -v pbpaste >/dev/null; then
	alias getclip='pbpaste';
	alias putclip='pbcopy';
elif command -v xclip >/dev/null; then
	alias getclip='xclip --out';
	alias putclip='xclip --in';
fi;

# Make "ctags" recurse by default.
if command -v ctags > /dev/null; then
	alias ctags='ctags --exclude={docs,cache,tiny_mce,layout} --recurse';
fi;

# Make the "sudo" prompt more useful, without requiring access to "visudo".
export SUDO_PROMPT='[sudo] password for %u on %h: ';

# Show what a given command really is. It is a combination of "type", "file"
# and "ls". Unlike "which", it does not only take $PATH into account. This
# means it works for aliases and hashes, too. (The name "whatis" was taken,
# and I did not want to overwrite "which", hence "wtfis".)
# The return value is the result of "type" for the last command specified.
function wtfis {
	local cmd type i=1 ret=0;
	if [ $# -eq 0 ]; then
		# Use "fc" to get the last command, and use that when no command
		# was given as a parameter to "wtfis".
		set -- $(fc -nl -1);
		while [ $# -gt 0 -a '(' "sudo" = "$1" -o "-" = "${1:0:1}" ')' ]; do
			# Ignore "sudo" and options ("-x" or "--bla").
			shift;
		done;
		# Replace the positional parameter array with the last command name.
		set -- "$1";
	fi;
	for cmd; do
		type="$(type "$cmd")";
		ret=$?;
		if [ $ret -eq 0 ]; then
			# Try to get the physical path. This works for hashes and
			# "normal" binaries.
			local path="$(type -p "$cmd")";
			if [ -z "$path" ]; then
				# Show the output from "type" without ANSI escapes.
				echo "${type//$'\e'/\\033}";

				case "$(command -v "$cmd")" in
					'alias')
						local alias_="$(alias "$cmd")";
						# The output looks like "alias foo='bar'"; so
						# strip everything except the body.
						alias_="${alias_#*\'}";
						alias_="${alias_%\'}";
						# Use "read" to process escapes. E.g. 'test\ it'
						# will # be read as 'test it'. This allows for
						# spaces inside command names.
						read -d ' ' alias_ <<< "$alias_";
						# Recurse and indent the output.
						# TODO: prevent infinite recursion
						wtfis "$alias_" 2>&2 | sed 's/^/  /';
						;;
					'keyword' | 'builtin')
						# Get the one-line description from the built-in
						# help, if available. Note that this does not
						# guarantee anything useful, though. Look at the
						# output for "help set", for instance.
						help "$cmd" 2> /dev/null | {
							local buf line;
							read -r line;
							while read -r line; do
								buf="$buf${line/.  */.} ";
								if [[ "$buf" =~ \.\ $ ]]; then
									echo "$buf";
									break;
								fi;
							done;
						};
						;;
				esac;
			else
				# For physical paths, get some more info.
				# First, get the one-line description from the man page.
				# ("col -b" gets rid of the backspaces used by OS X's man
				# to get a "bold" font.)
				(COLUMNS=10000 man "$(basename "$path")" 2>/dev/null) | col -b | \
				awk '/^NAME$/,/^$/' | {
					local buf line;
					read -r line;
					while read -r line; do
						buf="$buf${line/.  */.} ";
						if [[ "$buf" =~ \.\ $ ]]; then
							echo "$buf";
							buf='';
							break;
						fi;
					done;
					[ -n "$buf" ] && echo "$buf";
				}

				# Get the absolute path for the binary.
				local full_path="$(
					cd "$(dirname "$path")" \
						&& echo "$PWD/$(basename "$path")" \
						|| echo "$path"
				)";

				# Then, combine the output of "type" and "file".
				local fileinfo="$(file "$full_path")";
				echo "${type%$path}${fileinfo}";

				# Finally, show it using "ls" and highlight the path.
				# If the path is a symlink, keep going until we find the
				# final destination. (This assumes there are no circular
				# references.)
				local paths=("$path") target_path="$path";
				while [ -L "$target_path" ]; do
					target_path="$(readlink "$target_path")";
					paths+=("$(
						# Do some relative path resolving for systems
						# without readlink --canonicalize.
						cd "$(dirname "$path")";
						cd "$(dirname "$target_path")";
						echo "$PWD/$(basename "$target_path")"
					)");
				done;
				local ls="$(command ls -fdalF "${paths[@]}")";
				echo "${ls/$path/$'\e[7m'${path}$'\e[27m'}";
			fi;
		fi;

		# Separate the output for all but the last command with blank lines.
		[ $i -lt $# ] && echo;
		let i++;
	done;
	return $ret;
}

# Try to make sense of the date. It supports everything GNU date knows how to
# parse, as well as UNIX timestamps. It formats the given date using the
# default GNU date format, which you can override using "--format='%x %y %z'.
#
# Examples of input and output:
#
#   $ whenis 1234567890            # UNIX timestamps
#   Sat Feb 14 00:31:30 CET 2009
#
#   $ whenis +1 year -3 months     # relative dates
#   Fri Jul 20 21:51:27 CEST 2012
#
#   $ whenis 2011-10-09 08:07:06   # MySQL DATETIME strings
#   Sun Oct  9 08:07:06 CEST 2011
#
#   $ whenis 1979-10-14T12:00:00.001-04:00 # HTML5 global date and time
#   Sun Oct 14 17:00:00 CET 1979
#
#   $ (TZ=America/Vancouver whenis) # Current time in Vancouver
#   Thu Oct 20 13:04:20 PDT 2011
#
# When requesting a different timezone like in the last example, make sure to
# execute the command in a subshell to avoid changing your timezone for the
# rest of the session.
#
# For more info, check out http://kak.be/gnudateformats.
function whenis {
	local error='Unable to parse that using http://kak.be/gnudateformats';

	# Default GNU date format as seen in date.c from GNU coreutils.
	local format='%a %b %e %H:%M:%S %Z %Y';
	if [[ "$1" =~ ^--format= ]]; then
		format="${1#--format=}";
		shift;
	fi;

	# Concatenate all arguments as one string specifying the date.
	local date="$*";
	if [[ "$date"  =~ ^[[:space:]]*$ ]]; then
		date='now';
	elif [[ "$date"  =~ ^[0-9]{13}$ ]]; then
		# Cut the microseconds part.
		date="${date:0:10}";
	fi;

	if [[ "$OSTYPE" =~ ^darwin ]]; then
		# Use PHP on OS X, where "date" is not GNU's.
		php -r '
			error_reporting(-1);
			$format = $_SERVER["argv"][1];
			$date = $_SERVER["argv"][2];
			if (!is_numeric($date)) {
				$date = strtotime($date);
				if ($date === false) {
					fputs(STDERR, $_SERVER["argv"][3] . PHP_EOL);
					exit(1);
				}
			}
			echo strftime($format, $date), PHP_EOL;
		' -- "$format" "$date" "$error";
	else
		# Use GNU date in all other situations.
		[[ "$date" =~ ^[0-9]+$ ]] && date="@$date";
		date -d "$date" +"$format";
	fi;
}

