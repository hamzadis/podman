#!/usr/bin/env bats   -*- bats -*-
#
# Tests for podman diff
#

load helpers

@test "podman diff" {
    n=$(random_string 10)          # container name
    rand_file=$(random_string 10)
    run_podman run --name $n $IMAGE sh -c "touch /$rand_file;rm /etc/services"

    # If running local, test `-l` (latest) option. This can't work with remote.
    if ! is_remote; then
        n=-l
    fi

    run_podman diff --format json $n

    # Expected results for each type of diff
    declare -A expect=(
        [added]="/$rand_file"
        [changed]="/etc"
        [deleted]="/etc/services"
    )

    for field in ${!expect[@]}; do
        result=$(jq -r -c ".${field}[]" <<<"$output")
        is "$result" "${expect[$field]}" "$field"
    done

    run_podman rm $n
}

# vim: filetype=sh
