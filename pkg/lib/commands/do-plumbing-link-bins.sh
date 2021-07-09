# shellcheck shell=bash

do-plumbing-link-bins() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	log.info "Linking bin files for '$package'"

	local remove_extensions=
	local -a bins=()

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_string "$bpm_toml_file" 'binRemoveExtensions'; then
			if [ "$REPLY" = 'yes' ]; then
				remove_extensions='yes'
			fi
		fi

		if util.get_toml_array "$bpm_toml_file" 'binDirs'; then
			for dir in "${REPLIES[@]}"; do
				for file in "$BPM_PACKAGES_PATH/$package/$dir"/*; do
					symlink_binfile "$file" "$remove_extensions"
				done
			done

			return
		fi

		fallback_symlink_bins "$package" "$remove_extensions"
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'REMOVE_EXTENSION'; then
			remove_extensions="$REPLY"
		fi

		if util.extract_shell_variable "$package_sh_file" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"

			for file in "${bins[@]}"; do
				symlink_binfile "$BPM_PACKAGES_PATH/$package/$file" "$remove_extensions"
			done
		else
			fallback_symlink_bins "$package" "$remove_extensions"
		fi
	else
		fallback_symlink_bins "$package" "$remove_extensions"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
# @arg $2 Whether to remove extensions
fallback_symlink_bins() {
	local package="$1"
	local remove_extensions="$2"

	if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
		for file in "$BPM_PACKAGES_PATH/$package"/bin/*; do
			symlink_binfile "$file" "$remove_extensions"
		done
	else
		for file in "$BPM_PACKAGES_PATH/$package"/*; do
			if [ -x "$file" ]; then
				symlink_binfile "$file" "$remove_extensions"
			fi
		done
	fi
}

# @description Symlink the bin file to the correct location
# @arg $1 The full path of the executable
# @arg $2 Whether to remove extensions
symlink_binfile() {
	local fullBinFile="$1"
	local remove_extensions="$2"

	local binName="${fullBinFile##*/}"

	if [[ "${remove_extensions:-no}" == @(yes|true) ]]; then
		binName="${binName%%.*}"
	fi

	mkdir -p "$BPM_INSTALL_BIN"
	ln -sf "$fullBinFile" "$BPM_INSTALL_BIN/$binName"
	chmod +x "$BPM_INSTALL_BIN/$binName"
}
