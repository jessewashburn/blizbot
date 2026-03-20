#!/usr/bin/env bats
# Smoke tests for list-prompts.sh
# Requires: bats-core, gh CLI authenticated
# Run: bats workspace/skills/promptroot/scripts/list-prompts.bats

SCRIPT="$(dirname "$BATS_TEST_FILENAME")/list-prompts.sh"

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

@test "returns at least one slug for promptroot/promptroot main" {
  run bash "$SCRIPT" promptroot/promptroot main
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  # Output should be slugs (no prompts/ prefix, no .md suffix)
  [[ "$output" != *"prompts/"* ]]
  [[ "$output" != *".md"* ]]
}

@test "output contains known slug tutorial/templates/versioned-modular-sdd-plan" {
  run bash "$SCRIPT" promptroot/promptroot main
  [ "$status" -eq 0 ]
  [[ "$output" =~ "tutorial/templates/versioned-modular-sdd-plan" ]]
}

@test "invalid repo returns non-zero exit code" {
  run bash "$SCRIPT" nonexistent-owner-xyz/nonexistent-repo-xyz main
  [ "$status" -ne 0 ]
  [[ "$output" =~ "not found" ]] || [[ "$output" =~ "Error" ]]
}
