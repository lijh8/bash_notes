#!/bin/bash

. echo.sh

# bash manual:

# The return value of a simple command is its exit status,
# or 128+n if the command is terminated by signal n.


# The return status is the exit status of the last command executed.

# AND and OR lists are sequences of one or more pipelines separated by
# the && and || control operators, respectively. AND and OR lists are
# executed with left associativity.

# An AND list has the form

# command1 && command2

# command2 is executed if, and only if, command1 returns an exit status
# of zero (success).

# An OR list has the form

# command1 || command2

# command2 is executed if, and only if, command1 returns a non-zero exit
# status. The return status of AND and OR lists is the exit status of the
# last command executed in the list.


# Special Parameters $?
# Expands to the exit status of the most recently executed foreground pipeline.

# The exit status of the last command is available in the special parameter $?.

# Shell builtin commands return a status of 0 (true) if successful, and
# non-zero (false) if an error occurs while they execute. All builtins
# return an exit status of 2 to indicate incorrect usage, generally
# invalid options or missing arguments.


# The exit status of a function definition is zero unless a syntax error
# occurs or a readonly function with the same name already exists.
# When executed, the exit status of a function is the exit status of the
# last command executed in the body.

# An exit status of zero indicates success.
# A non-zero exit status indicates failure.


#---


# In Bash, the return value of a function is its exit status,
# which is an integer value between 0 and 255.
# This exit status is used to indicate the success or failure of the function.

# In Bash, the return statement is used to return an exit status code
# from a function, not a value. To return values from a function in Bash,
# you typically use command substitution or global variables.

# Using Command Substitution

(
sum1() {
    a="$1"
    b="$2"
    printf $(( a + b ))
}

result=$(sum1 100 20)
echo $result
)


# Using Global Variable

(
sum2() {
    result=$(($1 + $2))
}

sum2 10 200
echo $result
)


#---


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

# bash manual:
# Changes made to the subshell environment cannot affect the shell's
# execution environment.

# local variable:
# this is a better way, it produces same result as subshell is used.

# bash manual:
# When local is used within a function, it causes the variable name to
# have a visible scope restricted to that function and its children.


# local variable:

g(){
    # ( # subshell
    # a="$1"
    echo "$a"
    local a=300 # local
    echo "$a"
    # ) # subshell
}

f(){
    # ( # subshell
    # a="$1"
    echo "$a"
    local a=200 # local
    echo "$a"
    g # "$a"
    echo "$a"
    # ) # subshell
}

# (
a=100
echo "$a"
f # "$a"
echo "$a"
# )


# function.sh:142:: 100
# function.sh:132:f: 100
# function.sh:134:f: 200
# function.sh:123:g: 200
# function.sh:125:g: 300
# function.sh:136:f: 200 # not 300, not affected by called function
# function.sh:144:: 100 # not 300, not affected by called function


#---


f() {
    # [aaa bbb],
    for a in "$*"; do # need quotes "$*"
        echo $a
    done

    # [aaa], [bbb],
    for a in "$@"; do
        echo $a
    done
}
f aaa bbb


#---

