#!/bin/bash

for i in {1..4}; do
    testcase="Testcase${i}"
    diff_dir="${testcase}Diff"

    rm -rf "$diff_dir"

    for file1 in "$testcase"/*.1.txt; do
        [ -f "$file1" ] || continue

        file2="${file1%.1.txt}.2.txt"

        if [ -f "$file2" ] && ! cmp -s "$file1" "$file2"; then
            mkdir -p "$diff_dir"
            base=$(basename "$file1" .1.txt)
            diff -u "$file1" "$file2" > "$diff_dir/${base}Diff.txt"
        fi
    done
done
