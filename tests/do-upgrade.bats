#!/usr/bin/env bats

load 'util/init.sh'

@test "simple upgrade" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BPM_CWD"

	do-upgrade "$pkg"

	run do-list --outdated
	assert_output ""

	assert [ -f "$BPM_PACKAGES_PATH/$pkg/script2.sh" ]
}

@test "symlinks stay valid after upgrade" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
		chmod +x 'script.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BPM_CWD"

	do-upgrade "$pkg"

	assert [ "$(readlink "$BPM_INSTALL_BIN/script.sh")" = "$BPM_PACKAGES_PATH/$pkg/script.sh" ]
}

@test "BPM_INSTALL_DIR reflected when package modifies binDirs key" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "binn" ]' > 'bpm.toml'
		mkdir 'binn'
		touch 'binn/script3.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	[ -f "$BPM_INSTALL_BIN/script3.sh" ]

	cd "$BPM_ORIGIN_DIR/$pkg"
	rm 'bpm.toml'
	git add .
	git commit -m 'Remove bpm.toml'
	cd "$BPM_CWD"

	do-upgrade "$pkg"

	assert [ ! -f "$BPM_INSTALL_BIN/script3.sh" ]
}
