#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

run_vm=0
[[ ${1:-} == --vm ]] && run_vm=1

total_pass=0
total_fail=0
total_skip=0

for t in test_assets.sh test_config.sh test_cli.sh test_iso.sh; do
    printf '%s\n' "Running $t"
    out=$(bash "./$t" 2>&1)
    status=$?
    printf '%s\n' "$out" | grep -v '^# pass=' || true
    line=$(printf '%s\n' "$out" | grep '^# pass=' | tail -n 1 || true)
    if [[ -z $line ]]; then
        printf 'FAIL: %s exited %d without a test summary\n' "$t" "$status" >&2
        total_fail=$((total_fail + 1))
        continue
    fi
    p=${line#*pass=}; p=${p%% *}
    f=${line#*fail=}; f=${f%% *}
    s=${line#*skip=}; s=${s%% *}
    total_pass=$((total_pass + ${p:-0}))
    total_fail=$((total_fail + ${f:-0}))
    total_skip=$((total_skip + ${s:-0}))
    if (( status != 0 && ${f:-0} == 0 )); then
        printf 'FAIL: %s exited %d despite reporting no assertion failures\n' "$t" "$status" >&2
        total_fail=$((total_fail + 1))
    fi
    echo
done

if (( run_vm )); then
    echo "Live boot in a virtual machine"
    bash ./vm-boot.sh
    case $? in
        0)  total_pass=$((total_pass + 1)) ;;
        77) total_skip=$((total_skip + 1)) ;;
        *)  total_fail=$((total_fail + 1)) ;;
    esac
    echo
fi

printf 'Total: %d passed, %d failed, %d skipped\n' "$total_pass" "$total_fail" "$total_skip"
(( total_fail == 0 ))
