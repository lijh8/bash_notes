#!/bin/bash
# main.sh

alias echo2='echo "$BASH_SOURCE":"$LINENO":"${FUNCNAME:-<FUNC>}": '

. echo2.sh

hello(){
    echo2 "hello function"
}

a="hello world"
echo2 "$a"
hello

# output:

# $ sh main.sh
# echo2.sh:8:<FUNC>: echo with source location
# main.sh:13:<FUNC>: hello world
# main.sh:9:hello: hello function
# $
