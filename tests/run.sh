#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

run_vm=0
[[ ${1:-} == --vm ]] && run_vm=1

total_pass=0
total_fail=0
total_skip=0

for t in test_assets.sh test_config.sh test_cli.sh test_iso.sh; do
    out=$(bash "./$t" 2>&1)
    printf '%s\n' "$out" | grep -v '^# pass='
    line=$(printf '%s\n' "$out" | grep '^# pass=' | tail -n 1)
    p=${line#*pass=}; p=${p%% *}
    f=${line#*fail=}; f=${f%% *}
    s=${line#*skip=}; s=${s%% *}
    total_pass=$((total_pass + ${p:-0}))
    total_fail=$((total_fail + ${f:-0}))
    total_skip=$((total_skip + ${s:-0}))
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
