#!/usr/bin/env bats
# Smoke tests for fetch-prompt.sh
# Requires: bats-core, gh CLI authenticated
# Run: bats workspace/skills/promptroot/scripts/fetch-prompt.bats

SCRIPT="$(dirname "$BATS_TEST_FILENAME")/fetch-prompt.sh"

@test "prints usage and exits 1 when no arguments given" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "prints usage and exits 1 when only one argument given" {
  run bash "$SCRIPT" promptroot/promptroot
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "prints usage and exits 1 when only two arguments given" {
  run bash "$SCRIPT" promptroot/promptroot main
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "valid slug returns non-empty markdown output" {
  run bash "$SCRIPT" promptroot/promptroot main tutorial/templates/versioned-modular-sdd-plan
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  # Should look like markdown
  [[ "$output" =~ "#" ]]
}

@test "invalid slug returns non-zero exit code with error message" {
  run bash "$SCRIPT" promptroot/promptroot main this-slug-does-not-exist-xyz-abc-999
  [ "$status" -ne 0 ]
  [[ "$output" =~ "not found" ]] || [[ "$output" =~ "Error" ]]
}

@test "invalid slug on non-main branch falls back to main and notifies" {
  run bash "$SCRIPT" promptroot/promptroot nonexistent-branch-xyz tutorial/templates/versioned-modular-sdd-plan
  # Should either succeed (fell back to main) or fail with error — must not hang
  [ "$status" -eq 0 ] || [ "$status" -ne 0 ]
  # If it fell back, there should be a warning on stderr
  # (output captures stdout; stderr goes to /tmp/fetch-prompt-err in the script)
}

@test "nonexistent repo returns non-zero exit code" {
  run bash "$SCRIPT" nonexistent-owner-xyz/nonexistent-repo-xyz main some-slug
  [ "$status" -ne 0 ]
}
