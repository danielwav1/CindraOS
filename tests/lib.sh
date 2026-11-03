ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI="$ROOT/scripts/cindra"
PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); printf '  ok    %s\n' "$1"; }
fail() { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$1"; [[ -n ${2:-} ]] && printf '        %s\n' "$2"; }
skip() { SKIP=$((SKIP + 1)); printf '  skip  %s (%s)\n' "$1" "$2"; }

expect_eq() {
    if [[ $2 == "$3" ]]; then pass "$1"; else fail "$1" "expected '$2', got '$3'"; fi
}

expect_contains() {
    if [[ $2 == *"$3"* ]]; then pass "$1"; else fail "$1" "output does not contain '$3'"; fi
}

expect_not_contains() {
    if [[ $2 != *"$3"* ]]; then pass "$1"; else fail "$1" "output contains '$3'"; fi
}

expect_file() {
    if [[ -f $2 ]]; then pass "$1"; else fail "$1" "missing file $2"; fi
}

cindra() {
    CINDRA_RELEASE_FILE="$ROOT/assets/branding/cindra-release" \
    CINDRA_OS_RELEASE="$ROOT/assets/branding/os-release" \
    CINDRA_SHARE_DIR="${CINDRA_SHARE_DIR:-/nonexistent}" \
    NO_COLOR=1 bash "$CLI" "$@"
}

finish() {
    printf '# pass=%d fail=%d skip=%d\n' "$PASS" "$FAIL" "$SKIP"
    (( FAIL == 0 ))
}
