setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "validate --strict pasa sin advertencias" {
  run claude plugin validate --strict .
  [ "$status" -eq 0 ]
}

@test "manifest declara nombre y versión 0.1.0" {
  [ "$(jq -r .name .claude-plugin/plugin.json)" = "sdd-harness" ]
  [ "$(jq -r .version .claude-plugin/plugin.json)" = "0.1.0" ]
  [ "$(jq -r '.dependencies // "none"' .claude-plugin/plugin.json)" = "none" ]
}
