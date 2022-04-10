#!/bin/bash
# main.sh

alias echo='echo "$BASH_SOURCE":"$LINENO":"${FUNCNAME:-<FUNC>}": '

. echo.sh

hello(){
    echo "hello function"
}

a="hello world"
echo "$a"
hello

# output:

# $ sh main.sh
# echo.sh:8:<FUNC>: echo with source location
# main.sh:13:<FUNC>: hello world
# main.sh:9:hello: hello function
# $
