#!/bin/bash
# echo.sh
# echo with source location.

# echo using an alias
shopt -s expand_aliases
alias echo2='echo "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME[0]}:"'

# or echo using a function
echo3(){
    local a
    read -a a <<< `caller`
    echo "${a[1]}:${a[0]}: $*"
}

echo4(){
    echo "`awk '{print $2 ":" $1}' <<< \`caller\` `: $*"
}

# bug: this shows main as FUNCNAME of the top level code outside any function
# echo5(){
#     echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]}:${FUNCNAME[1]}: $*"
# }

# source this file or just copy the two lines for alias
# source echo.sh
# . echo.sh

# test
# echo "hello"
# echo2 "hello bash"
# echo3 "hello bash"
