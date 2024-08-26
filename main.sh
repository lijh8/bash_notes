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

# number

a="  11  "
b=10
a=${a// /}  # trim spaces
b=${b// /}  # trim spaces
echo $(( a > b ))
echo $(( a < b ))
echo $(( a == b ))

# string

    a="  bb  "
    b=bb
    a=${a// /}  # trim spaces
    b=${b// /}  # trim spaces
    true="true"
    false="false"
    c1=$([[ "$a" > "$b" ]] && printf "$true" || printf "$false")
    c2=$([[ "$a" < "$b" ]] && printf "$true" || printf "$false")
    c3=$([[ "$a" == "$b" ]] && printf "$true" || printf "$false")
    echo "$c1"
    echo "$c2"
    echo "$c3"
