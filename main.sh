#!/bin/bash
# main.sh

. echo.sh

f() {
    # [aaa bbb],
    for a in "$*"; do # need quotes "$*"
        printf "[%s], " "$a" # need quotes "$a"
    done
    printf "\n"

    # [aaa], [bbb],
    for a in "$@"; do
        printf "[%s], " "$a"
    done
    printf "\n"
}
f aaa bbb

