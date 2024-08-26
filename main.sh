#!/bin/bash
# main.sh

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO:"' # $FUNCNAME

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

echo "----------"
echo "----------"
alias echo='echo "$BASH_SOURCE:$LINENO:$FUNCNAME:aaa: "' # $FUNCNAME

g(){
    (
    # a="$1"
    echo "$a"
    a=300
    echo "$a"
    )
}

f(){
    (
    # a="$1"
    echo "$a"
    a=200
    echo "$a"
    g # "$a"
    echo "$a"
    )
}

(
a=100
echo "$a"
f # "$a"
echo "$a"
)
