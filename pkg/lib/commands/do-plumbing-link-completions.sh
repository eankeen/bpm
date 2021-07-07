# shellcheck shell=bash

bpm-plumbing-link-completions() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local -a bash_completions=() zsh_completions=()

	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"
	if [ -f "$packageShFile" ]; then
		util.extract_shell_variable "$packageShFile" 'BASH_COMPLETIONS'
		IFS=':' read -ra bash_completions <<< "$REPLY"

		util.extract_shell_variable "$packageShFile" 'ZSH_COMPLETIONS'
		IFS=':' read -ra zsh_completions <<< "$REPLY"
	fi

	for completion in "${bash_completions[@]}"; do
		mkdir -p "$BPM_INSTALL_COMPLETIONS/bash"
		ln -sf "$BPM_PACKAGES_PATH/$package/$completion" "$BPM_INSTALL_COMPLETIONS/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -sq "#compdef" "$target"; then
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compsys"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${completion##*/}"
		else
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compctl"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${completion##*/}"
		fi
	done
}
