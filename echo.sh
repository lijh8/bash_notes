#!/bin/bash
# echo.sh
# echo with source location.

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO:$FUNCNAME:"'

# source this file or just copy the two lines for alias
# source echo.sh
# . echo.sh

# test
# echo "hello"
