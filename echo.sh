#!/bin/bash
# echo.sh

# echo with source location. source this file or just use the alias

shopt -s expand_aliases
alias echo='echo $BASH_SOURCE:$LINENO:$FUNCNAME: '

echo "echo with source location"
