#!/usr/bin/env bats
# Proves scripts/hooks/commit-msg rejects a trailer, a wrong email and a bad title on a throwaway branch.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  WORK="$(mktemp -d)"
  git -C "$WORK" init -q -b main
  mkdir -p "$WORK/.github" "$WORK/scripts/hooks"
  printf 'allowed@example.test\n' > "$WORK/.github/allowed-author"
  cp "$REPO_ROOT/scripts/hooks/commit-msg" "$WORK/scripts/hooks/commit-msg"
  chmod +x "$WORK/scripts/hooks/commit-msg"
  git -C "$WORK" config core.hooksPath scripts/hooks
  git -C "$WORK" config user.name tester
  git -C "$WORK" config user.email allowed@example.test
  git -C "$WORK" config commit.gpgsign false
  git -C "$WORK" checkout -q -b throwaway
  printf 'x\n' > "$WORK/file.txt"
  git -C "$WORK" add file.txt
}

teardown() {
  rm -rf "$WORK"
}

@test "accepts a conventional title from the allowed author" {
  run git -C "$WORK" commit -q -m "chore: add file"
  [ "$status" -eq 0 ]
}

@test "rejects a Co-authored-by trailer" {
  run git -C "$WORK" commit -q -m "chore: add file" -m "Co-authored-by: Someone <someone@example.test>"
  [ "$status" -ne 0 ]
  [[ "$output" == *"trailers are not allowed"* ]]
}

@test "rejects a wrong author email" {
  run git -C "$WORK" -c user.email=other@example.test commit -q -m "chore: add file"
  [ "$status" -ne 0 ]
  [[ "$output" == *"author email does not match"* ]]
}

@test "rejects a title that is not a conventional commit" {
  run git -C "$WORK" commit -q -m "Added a file"
  [ "$status" -ne 0 ]
  [[ "$output" == *"title must match"* ]]
}

@test "leaves no commit on the throwaway branch after rejections" {
  run git -C "$WORK" commit -q -m "bad title"
  run git -C "$WORK" rev-parse --verify -q HEAD
  [ "$status" -ne 0 ]
}
