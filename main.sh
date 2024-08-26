#!/bin/bash
# main.sh

shopt -s expand_aliases
alias echo='echo $BASH_SOURCE:$LINENO:$FUNCNAME: '

. echo.sh

hello(){
    echo "hello function"
}

a="hello world"
echo "$a"
hello


# output:

# $ sh main.sh
# echo.sh:9:: echo with source location
# main.sh:14:: hello world
# main.sh:10:hello: hello function
# $
# $ bash main.sh
# echo.sh:9:: echo with source location
# main.sh:14:: hello world
# main.sh:10:hello: hello function
# $

