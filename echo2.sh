#!/bin/bash
# echo2.sh

# echo with source location. source this file or just use the alias

alias echo2='echo "$BASH_SOURCE":"$LINENO":"${FUNCNAME:-<FUNC>}": '

echo2 "echo with source location"
