# shellcheck shell=bash

eval "$(basalt-package-init)" || exit
basalt.package-init
basalt.package-load
# basalt.load 'github.com/hyperupcall/bats-all' 'load.bash' || exit

load './util/test_util.sh'

load "$BASALT_PACKAGE_DIR/pkg/src/cmd/TEMPLATE_SLUG.sh"
TEMPLATE_SLUG() { main.TEMPLATE_SLUG "$@"; }

export NO_COLOR=

setup() {
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
