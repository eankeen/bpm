# shellcheck shell=bash

do-list() {
	util.init_local

	if (($# != 0)); then
		bprint.warn "No arguments or flags must be specified"
	fi

	if util.get_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies'; then
		for dependency in "${REPLIES[@]}"; do
			util.get_package_info "$dependency"
			local url="$REPLY2" version="$REPLY5"
			printf '%s\n' "$url@$version"
		done
	fi
}
