#!/bin/bash

overall=0

for i in {1..4}; do
    testcase="Testcase${i}"
    diff_dir="${testcase}Diff"
    failed=0
    expected_count=0

    for file1 in "$testcase"/*.1.txt; do
        [ -f "$file1" ] || continue

        file2="${file1%.1.txt}.2.txt"
        [ -f "$file2" ] || continue

        base=$(basename "$file1" .1.txt)
        output="$diff_dir/${base}Diff.txt"

        if cmp -s "$file1" "$file2"; then
            if [ -e "$output" ]; then
                failed=1
            fi
        else
            expected_count=$((expected_count + 1))

            if [ ! -f "$output" ]; then
                failed=1
            elif ! diff -u <(diff -u "$file1" "$file2" | tail -n +3) <(tail -n +3 "$output") > /dev/null; then
                failed=1
            fi
        fi
    done

    if [ "$expected_count" -eq 0 ]; then
        if [ -e "$diff_dir" ]; then
            failed=1
        fi
    elif [ ! -d "$diff_dir" ]; then
        failed=1
    fi

    if [ -d "$diff_dir" ]; then
        for output in "$diff_dir"/*; do
            [ -e "$output" ] || continue

            if [ ! -f "$output" ]; then
                failed=1
                continue
            fi

            name=$(basename "$output")

            case "$name" in
                *Diff.txt) base="${name%Diff.txt}" ;;
                *) failed=1; continue ;;
            esac

            file1="$testcase/${base}.1.txt"
            file2="$testcase/${base}.2.txt"

            if [ ! -f "$file1" ] || [ ! -f "$file2" ] || cmp -s "$file1" "$file2"; then
                failed=1
            fi
        done
    fi

    if [ "$failed" -eq 0 ]; then
        echo "Testcase${i}: PASS"
    else
        echo "Testcase${i}: FAIL"
        overall=1
    fi
done

exit "$overall"
