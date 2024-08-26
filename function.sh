#!/bin/bash

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO:$FUNCNAME:"'

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


is_integer() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}

a=123
is_integer $a
echo $?
is_integer $a && echo true || echo false

a=-123
is_integer $a
echo $?
is_integer $a && echo true || echo false

a=abc
is_integer $a
echo $?
is_integer $a && echo true || echo false

a=3.14
is_integer $a
echo $?
is_integer $a && echo true || echo false


#---


# calculate the sum of an integer and a floating-point number using
# external utilities like bc or awk, as Bash itself does not natively
# handle floating-point arithmetic.

is_float() {
    [[ $1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
}

integer=10
float=20.5
is_float $integer && echo true || echo false
is_float $float && echo true || echo false

# Calculate the sum using awk
sum=$(awk "BEGIN {print $integer + $float}")
echo $sum


#---

