#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    printf 'Usage: bash %s <zig_learning executable> <zig compiler>\n' "$0" >&2
    exit 2
fi

exe=$(realpath -- "$1")
zig=$(realpath -- "$2")
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
solutions="$script_dir/solutions"
temp=$(mktemp -d "${TMPDIR:-/tmp}/Zig 中文 smoke.XXXXXXXX")
trap 'rm -rf -- "$temp"' EXIT
learn="$temp/workspace"

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

invoke_learning() {
    local expected=$1 code
    shift
    # Compiler failures are intentional; check their exit codes explicitly.
    if output=$("$exe" "$@" 2>&1); then
        code=0
    else
        code=$?
    fi
    printf '%s\n' "$output"
    if [[ $code -ne $expected ]]; then
        fail "Expected exit $expected, got $code for: $*"
    fi
}

assert_contains() {
    [[ $output == *"$1"* ]] || fail "Missing '$1' in: $output"
}

assert_bytes() {
    cmp -s -- "$1" "$2" || fail "File changed: $2"
}

invoke_learning 0 init "$learn"
invoke_learning 0 list --path "$learn"
assert_contains '0/36'
invoke_learning 0 hint 01_values --level 3 --path "$learn"
for level in 1 2 3; do
    assert_contains "$level"
done
progress="$learn/.zig-learning/progress.json"
first="$learn/exercises/01_values.zig"
cp -- "$progress" "$temp/saved-progress"
cp -- "$first" "$temp/saved-source"
invoke_learning 2 init "$learn"
assert_bytes "$temp/saved-progress" "$progress"
assert_bytes "$temp/saved-source" "$first"
shopt -s nullglob
files=("$solutions"/*.zig)
[[ ${#files[@]} -eq 36 ]] || fail 'Expected 36 reference solutions'
for file in "${files[@]}"; do
    id=${file##*/}
    invoke_learning 1 run "${id%.zig}" --path "$learn" --zig "$zig"
done
invoke_learning 0 list --path "$learn"
assert_contains '0/36'
cp -- "$solutions/01_values.zig" "$first"
invoke_learning 0 run 01_values --path "$learn" --zig "$zig"
invoke_learning 0 list --path "$learn"
assert_contains '1/36'
invoke_learning 0 list --path "$learn"
assert_contains '1/36'
correct=$(<"$first")
printf '%s\n' "${correct//42/41}" > "$first"
invoke_learning 0 list --path "$learn"
assert_contains '已修改'
assert_contains '0/36'
invoke_learning 1 run 01_values --path "$learn" --zig "$zig"
# No learner tests remain: an incorrect public implementation must still fail.
printf '%s\n' 'pub fn answer() u8 { return 41; }' > "$first"
invoke_learning 1 run 01_values --path "$learn" --zig "$zig"
cp -- "$solutions/01_values.zig" "$first"
invoke_learning 0 run 01_values --path "$learn" --zig "$zig"
cp -- "$progress" "$temp/saved-progress"
invoke_learning 2 run unknown --path "$learn"
assert_bytes "$temp/saved-progress" "$progress"
invoke_learning 2 run 02_variables --path "$learn" --zig "$learn/missing-zig"
assert_bytes "$temp/saved-progress" "$progress"
second="$learn/exercises/02_variables.zig"
mv -- "$second" "$second.backup"
invoke_learning 2 run 02_variables --path "$learn" --zig "$zig"
assert_bytes "$temp/saved-progress" "$progress"
mv -- "$second.backup" "$second"
printf '%s' '{broken' > "$progress"
cp -- "$progress" "$temp/broken-progress"
invoke_learning 2 list --path "$learn"
assert_bytes "$temp/broken-progress" "$progress"
cp -- "$temp/saved-progress" "$progress"
cp -- "${files[@]}" "$learn/exercises/"
invoke_learning 0 verify --path "$learn" --zig "$zig"
invoke_learning 0 list --path "$learn"
assert_contains '36/36'
for command in run watch; do
    invoke_learning 0 "$command" --path "$learn" --zig "$learn/missing-zig"
    assert_contains '全部 36 道练习已完成'
done
printf '%s\n' 'SMOKE PASS: 36 starters rejected, 36 solutions accepted; CLI state/error checks passed.'
