# shellcheck shell=bash

init.ensure_bash_version() {
	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		printf '%s\n' 'Fatal: Basalt: Basalt requires at least Bash version 4.3' >&2
		exit 1
	fi
}

init.full_initialization() {
	# All files are already sourced when testing. This ensures stubs are not overriden
	if [ "$BASALT_IS_TESTING" != 'yes' ]; then
		init.common_init

		if [ -z "$__basalt_dirname" ]; then
			printf '%s\n' "Fatal: Basalt: Variable '__basalt_dirname' is empty"
			exit 1
		fi
		for f in "$__basalt_dirname"/pkg/vendor/bash-{core,std,term,toml}/pkg/src/**/?*.sh; do
			source "$f"
		done; unset -v f
		for f in "$__basalt_dirname"/pkg/src/{commands,plumbing,util}/?*.sh; do
			source "$f"
		done; unset -v f
	fi
}

init.get_global_repo_path() {
	unset -v REPLY; REPLY=

	local basalt_global_repo=
	if [ -L "$0" ]; then # Only subshell when necessary
		if ! basalt_global_repo=$(readlink -f "$0"); then
			printf '%s\n' "printf '%s\n' \"Fatal: Basalt: Invocation of readlink failed\" >&2"
			printf '%s\n' 'exit 1'
		fi
		basalt_global_repo=${basalt_global_repo%/*}
	else
		basalt_global_repo=${0%/*}
	fi
	basalt_global_repo=${basalt_global_repo%/*}
	basalt_global_repo=${basalt_global_repo%/*}

	REPLY=$basalt_global_repo
}

init.print_package_init() {
	init.get_global_repo_path
	local basalt_global_repo="$REPLY"

	printf '%s\n' "# shellcheck shell=bash

_____pacakge_init() {
		export BASALT_GLOBAL_REPO=\"$basalt_global_repo\"
}"
	cat "$basalt_global_repo/pkg/share/scripts/basalt-package-init.sh"
}

init.common_init() {
	set -eo pipefail
	shopt -s extglob globasciiranges nullglob shift_verbose
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
		LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
		LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export GIT_TERMINAL_PROMPT=0
}
