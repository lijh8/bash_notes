#!/bin/bash
# main.sh

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO:$FUNCNAME:"' # $FUNCNAME

g(){
    ( # subshell
    # a="$1"
    echo "$a"
    a=300
    echo "$a"
    ) # subshell
}

f(){
    ( # subshell
    # a="$1"
    echo "$a"
    a=200
    echo "$a"
    g # "$a"
    echo "$a"
    ) # subshell
}

(
a=100
echo "$a"
f # "$a"
echo "$a"
)

#
# variables in calling function may be changed by called functions,
# if the variables are defined before the function call happens.

# Function Calls:
# A called function operates in the same shell context as the
# calling function and can access its variables,
# provided they are in scope and visible at the time of the call.

# Subshells:
# Enclosing commands in parentheses creates a subshell.
# Changes to variables in a subshell do not affect the parent shell,
# providing isolation for variable changes.


# without subshell:

# main.sh:57:: 100
# main.sh:47:f: 100
# main.sh:49:f: 200
# main.sh:38:g: 200
# main.sh:40:g: 300
# main.sh:51:f: 300
# main.sh:59:: 300
#

# with subshell:

# main.sh:57:: 100
# main.sh:47:f: 100
# main.sh:49:f: 200
# main.sh:38:g: 200
# main.sh:40:g: 300
# main.sh:51:f: 200 # not 300, not affected by functions it calls
# main.sh:59:: 100 # not 300, not affected by functions it calls
#
