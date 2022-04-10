#!/bin/bash
# echo.sh

# echo with source location. source this file or just use the alias

alias echo='echo "$BASH_SOURCE":"$LINENO":"${FUNCNAME:-<FUNC>}": '

echo "echo with source location"
