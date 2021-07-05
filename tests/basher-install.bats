#!/usr/bin/env bats

load 'util/init.sh'

@test "executes install steps in right order" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install username/package
	assert_success "basher-plumbing-clone false github.com username package
basher-plumbing-deps username/package
basher-plumbing-link-bins username/package
basher-plumbing-link-completions username/package
basher-plumbing-link-completions username/package"
}

@test "with site, overwrites site" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install site/username/package

	assert_line "basher-plumbing-clone false site username package"
}

@test "without site, uses github as default site" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install username/package

	assert_line "basher-plumbing-clone false github.com username package"
}

@test "using ssh protocol" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install --ssh username/package

	assert_line "basher-plumbing-clone true github.com username package"
}

@test "installs with custom version" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install username/package@v1.2.3

	assert_line "basher-plumbing-clone false github.com username package v1.2.3"
}

@test "empty version is ignored" {
	test_util.mock_command basher-plumbing-clone
	test_util.mock_command basher-plumbing-deps
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions

	run basher-install username/package@

	assert_line "basher-plumbing-clone false github.com username package"
}

@test "doesn't fail" {
	create_package username/package
	test_util.mock_command _clone

	run basher-install username/package
	assert_success
}
