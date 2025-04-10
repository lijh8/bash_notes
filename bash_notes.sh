#!/bin/bash

# ShellCheck, a static analysis tool for shell scripts
# https://github.com/koalaman/shellcheck
# recommended by Google Shell Style Guide
# $ apt install shellcheck
# $ shellcheck hello.sh

#---

set -u # report unassigned or unbound variable

# source location

echo2(){
  echo "`caller | sed -E 's/([^ ]+) +([^ ]+)/\2:\1/'`: $*"
}

# using an alias
shopt -s expand_aliases
alias echo3='echo "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME[0]}:"'

#---

# is_integer

# check if a value is integer
# use ((, )) for integer arithmetic
# it supports decimal, octal, hexadecimal
# it does not support scientific notation
is_integer() {
  # 10, 20,
  declare re="^[+-]?([1-9][0-9]*|0[0-7]*|0[Xx][0-9A-Fa-f]+)$"
  [[ $1 =~ $re ]]
}

# is_float

# check if a value is a floating-point number
# with scientific notation support
# use awk for floating point arithmetic
# it does not support octal, hexadecimal
is_float(){
  # 3.14, 3.14E2,
  declare re="^[+-]?([0-9]+[.][0-9]*|[.][0-9]+)([Ee][+-]?[0-9]+)?$"
  [[ $1 =~ $re ]]
}

#---

# sourcing

# source a file and call function from it
#
#   source foo.sh
#   . foo.sh
#   foo
#   foo abc 123 # with args if needed

#---

# declare

# declare local variable in a function to not to pollute caller's scope
#
#   declare name=foo
#   declare -i num=123
#
# associative array must be declared
#
#   declare -A arr;
#
# declare indexed array with -a
#
#   declare -a arr;
#
# integer with declare -i
#
#   declare -i num=0
#   num=10      # ok
#   num=3.14    # invalid, unbound variable
#   num="abc"   # invalid, unbound variable
#
#   - invalid assignment will be reported with:
#       set -u;
#   - direct arithmetic without ((, ))
#   - comparison still needs ((, ))
#
#   declare -i a=10 b=20 c=0
#   c=a+b               # no spaces
#   c=$a+$b             # no spaces
#
#   c=$(( a + b))       # no spaces around assignment = operator
#   c=$(( $a + $b ))
#
#   (( a = b ))         # assignment
#   (( a == b ))        # equality
#
#   (( a < b))          && echo2 "less than"
#   (( a == b))         && echo2 "equal to"
#   (( a < b && a < c)) && echo2 "..."
#   (( a < b || a < c)) && echo2 "..."
#
# separate declare from command substitution
# declare does not propagate the exit status from the command substitution.
# https://google.github.io/styleguide/shellguide.html
# it applies to function too, a functions is called the same way as command.
#
#   declare name=$(cmd)       # no
#   if (( $? == 0 ))
#
#   declare name              # ok
#   name=$(cmd)               # ok
#   if (( $? == 0 ))

#---

# variable or parameter expansion

# The braces are required when parameter is a positional parameter with more than one digit,
# or when parameter is followed by a character that is not to be interpreted as part of its name.
#
#     "$0"
#    "${0}"
#   "${10}"     # braces required
# "foo${0}bar"  # braces required

#---

# integer

# integer with declare -i
#
#   declare -i num=0
#
#   declare ret=""    # output
#   declare -i err=0  # exit status
#   ret=$(cmd)        # command substitution or function call
#   err=$?            # retrieve exit status
#
# use ((, )) for decimal, octal, hexadecimal integer arithmetic
#   - operators   * / % + - etc
#   - assignment  = *= /= %= += -= etc
#
# use ((, )) for integer conditional comparison
#   - operators   == != < > <= >=
#   - logical     && || !

#   declare -i a=10 b=20 c=0
#   c=$(( a + b))
#   c=$(( $a + $b ))  # dollar $ sign is optional
#   (( a < b))      && echo "less than"
#   (( a == b))     && echo "equal to"
#   (( a = b ))     # assignment
#
#
# optional dollar sign and quoting
#
#   declare -i var=0
#   ((   var  == 0 ))
#   ((  $var  == 0 ))
#   (( "$var" == 0 ))
#
#   - operands are numbers inside ((, ))
#   - a non-number name denotes integer variable inside ((, ))
#   - variable name starts with a letter or underscore
#   - dollar $ sign before variable name is optional
#   - quoting is optional since number does not contains spaces

# float

# use awk for floating point arithmetic, scientific notation supported
#
#   declare a=3.14 b
#   b=`awk "BEGIN{ print $a + $a }"`
#   echo2 $b

# string

# string concatenation or interpolation:
#
#   declare s1="hello" s2
#   s2="$1 world"
#
# use [[, ]] for string conditional comparison
#   - operators   == != < >
#   - logical     && || !
#
#   declare a=abc b=abc err
#   [[ $a == $b ]] && echo2 "equal"
#   [[ $a < $b ]] && echo2 "less than"
#   [[ $a < $b || $a = $b ]]; err=$?; echo2 $err
#
# use [[, ]] for regex with =~
#   - regex in =~ should be unquoted
#   - use a variable for regex in =~ in case it contains spaces
#
#   declare text=100
#   declare re="^[+-]?([1-9][0-9]*|0[0-7]*|0[Xx][0-9A-Fa-f]+)$"
#   [[ $text =~ $re ]] && echo2 "integer: $text"

# command or function

# cmd
# err=$?
# ! cmd
#
# shortcut evaluation of logical expression
#
# 1. true if both are true, cmd2 is executed only if cmd1 succeeds.
#   cmd1 && cmd2
#
# 2. true if either is true, cmd2 is executed only if cmd1 fails.
#   cmd1 || cmd2
#
# cmd1 && cmd2 && cmd3  # if both succeed, then cmd3
# cmd1 || cmd2 && cmd3  # if either succeeds, then cmd3
# cmd1 && cmd2 || cmd3  # if either fails, then cmd3
#
# true && true || echo2 "cmd3"
# false && true || echo2 "cmd3"
# true && false || echo2 "cmd3"
# false && false || echo2 "cmd3"
#
# f1(){
#   a=10 b=20 c=30
#   # a=10 b=2 c=30
#   # a=10 b=20 c=3
#   # a=10 b=2 c=3
#   (( a < b )) && (( a < c )) && echo2 "$a, $b, $c"
#   (( a < b )) || (( a < c )) && echo2 "$a, $b, $c"
#   (( a < b )) && (( a < c )) || echo2 "$a, $b, $c"
#
#   (( a < b )) || (( a < c )) || echo2 "$a, $b, $c"
#   ! (( a < b )) && ! (( a < c )) && echo2 "$a, $b, $c"
# }
#
# f2(){
#   declare -r a="/tmp"
#   declare -r a="/tmp/an_inexistent_directory_for_test"
#
#   # without if statement
#   cd $a && ls || echo2 "wrong path"
#
#   # with if statement
#   if cd $a
#   then ls
#   else echo2 "wrong path"
#   fi
# }
#
# f3(){
#   declare -a arr=(
#     0 00 1 01 10 +10 -10
#     07 007 0xff 0x00ff
#     3.14 +3.14 -3.14
#     3.14E2 3.14E+2 3.14E-2
#     3. .3 .14 33.
#     abc 08 008 0xgg a10 10a a3.14 3.14a
#   )
#   for i in ${arr[@]}
#   do
#     is_integer $i && echo2 "integer: $i + $i = $(( $i + $i ))"
#     is_float $i && echo2 "float: $i + $i = $(awk "BEGIN{print $i + $i}")"
#     ! is_integer $i && ! is_float $i && echo2 "err: $i"
#   done
# }

#---

# spaces

# 1. no spaces around assignment operator
#   - assignment is shell syntax and it is not command
#   - with spaces it will be wrongly parsed as command
#   var=value
#
# 2. no spaces around redirection operator
#   cmd 2>/dev/null
#   cmd >/dev/null 2>&1
#
# 3. spaces are required around operators and operands
#   - for builtin [, [[, test command, expr command
#   - for those operators and operands are arguments to these commands

#---

# escape

#   - in test command escape \<, \>  , or they are redirection
#   - Ansi-C quoting $'\n'

#---

# quoting

# quoting variables and values may have spaces or special characters
# double quoting
#   - variable parameter expansion $
#   - backtick `
#   - escape \
#
#   declare foo="abc 123"
#   declare bar="$foo"
#   bar="`date`"

#---

# list

# { list; }
# list of group command must be terminated with newline or semicolon;
# spaces needed around list to separate it from braces;
#
#   { echo2; }
#
#   {
#     echo2
#   }
#

#---

# 3.2.4 Lists of Commands

#   command1 && command2
# command2 is executed only if command1 returns exit status of zero (success).
#
#   command1 || command2
# command2 is executed only if command1 returns non-zero exit status.
#
#   if test-commands; then
#     consequent-commands;
#   fi
#
# The test-commands list is executed, and if its return status is zero,
# the consequent-commands list is executed.

# 3.2.5.2 Conditional Constructs

# (( expression ))
#
# The arithmetic expression is evaluated,
# If the value of the expression is non-zero, the return status is 0;
# otherwise the return status is 1.
#
# or, if expression is non-zero (logical true), the return status is 0 (success);
# otherwise the return status is 1 (failure).
#
# [[ expression ]]
#
# Return a status of 0 or 1 depending on
# the evaluation of the conditional expression.
#
# K&R C 2nd, 2.6:
# the numeric value of a relational or logical expression
# is 1 if the relation is true, and 0 if the relation is false.
#
#
#  (( 0 ));       echo2 $?  # 1, failure, number
#  (( 0 != 0 ));  echo2 $?  # 1, failure
#  (( 1 != 1 ));  echo2 $?  # 1, failure
#  (( 0 == 0 ));  echo2 $?  # 0
#  (( 1 == 1 ));  echo2 $?  # 0
#  (( 1 ));       echo2 $?  # 0, number
#  (( 123 ));     echo2 $?  # 0
#  (( "123" ));   echo2 $?  # 0
#  (( 123 + 1 )); echo2 $?  # 0
#
#  echo2 ""
#
#  [[ 0 -ne 0 ]]; echo2 $?  # 1, failure
#  [[ 1 -ne 1 ]]; echo2 $?  # 1, failure
#  [[ 0 != 0 ]];  echo2 $?  # 1, failure
#  [[ 1 != 1 ]];  echo2 $?  # 1, failure
#  [[ 0 -eq 0 ]]; echo2 $?  # 0
#  [[ 1 -eq 1 ]]; echo2 $?  # 0
#  [[ 0 == 0 ]];  echo2 $?  # 0
#  [[ 1 == 1 ]];  echo2 $?  # 0
#  [[ 0 ]];       echo2 $?  # 0, string
#  [[ 1 ]];       echo2 $?  # 0, string
#  [[ 123 ]];     echo2 $?  # 0
#  [[ abc ]];     echo2 $?  # 0
#  [[ "abc" ]];   echo2 $?  # 0
#

# 3.3 Shell Functions

# Shell functions are a way to group commands for later execution
# using a single name for the group.
# They are executed just like a "regular" command.

# 3.7.5 Exit Status

# a command which exits with a zero exit status has succeeded.
# A non-zero exit status indicates failure.
#
# 4.1 Bourne Shell Builtins
#
#   test
#   [
#
#   test expr
#
# Evaluate a conditional expression expr
# and return a status of 0 (true) or 1 (false).

# 6.4 Bash Conditional Expressions

# Conditional expressions are used by the [[ compound command
# and the test and [ builtin commands
#
#   string1 == string2
# true if the strings are equal.
#
#   string1 < string2
# true if string1 sorts before string2 lexicographically.
#
#   arg1 OP arg2
# OP is one of ‘-eq’, ‘-lt’, ..,
# These arithmetic return true if arg1 is equal to, less than, .., arg2.
# When used with the [[, arg1 and arg2 are evaluated as arithmetic expressions.

# 6.5 Shell Arithmetic

# The shell allows arithmetic expressions to be evaluated,
# as one of the shell expansions or by using the (( compound command
#
#   (( 10 < 20 )) && echo2 "<"
#   echo2 $?
#   [[ "abc" < "efg" ]] && echo2 "<"
#   echo2 $?
#
#   test "abc" \< "efg" && echo2 "<"
#   echo2 $?
#   [ "abc" \< "efg" ] && echo2 "<"
#   echo2 $?

#---

# examples

slice_range_tuple(){

  # slice: ${parameter:offset:length} expansion

  declare -a arr=(aaa bbb ccc ddd eee fff)
  for i in ${arr[@]:2:3}
  do echo2 $i
  done

  # range: brace expansion sequence

  declare -a arr
  declare s x y

  s="foo bar baz"
  arr=($s)
  x=0
  y=$(( ${#arr[@]} - 1 ))

  for i in `eval echo {$x..$y}`
  do echo2 ${arr[$i]}
  done

  # tuple

  declare -a a=(aaa bbb ccc)
  declare -a b=(aaa bbb ccc)
  declare s="aaa bbb ccc"
  echo2 ${a[@]}

  a=(aaa bbb ccc)
  b=($s)
  read -a b <<< "aaa bbb ccc"

  [[ ${a[@]} == ${b[@]} ]] && echo2 "==" || echo2 "!="
  [[ ${a[@]} < ${b[@]} ]] && echo2 "<" || echo2 ">="

}

regex1(){
  # ${BASH_REMATCH[0]}
  #   - match the entire matched result
  # ${BASH_REMATCH[1]}, ${BASH_REMATCH[2]}, ...
  #   - match parenthesized capture groups

  declare text re ret err

  text="aaa 100 bbb 200 ccc"
  re='^[a-z]+[ ]+([0-9]+)[ ]+[a-z]+[ ]+([0-9]+)[ ]+[a-z]+$'

  # regex with =~ should be unquoted
  # use a variable for regex in case it contaons spaces

  # if [[ $text =~ ^[a-z]+[ ]+([0-9]+)[ ]+[a-z]+[ ]+([0-9]+)[ ]+[a-z]+$ ]]   # no
  # if [[ $text =~ '^[a-z]+[ ]+([0-9]+)[ ]+[a-z]+[ ]+([0-9]+)[ ]+[a-z]+$' ]] # no
  # if [[ $text =~ "^[a-z]+[ ]+([0-9]+)[ ]+[a-z]+[ ]+([0-9]+)[ ]+[a-z]+$" ]] # no
  # if [[ $text =~ "$re" ]]                                                  # no

  if [[ $text =~ $re ]] # ok
  then
    # slice: ${parameter:offset} expansion
    for i in ${BASH_REMATCH[@]:1}
    do echo2 "$i"
    done
  fi

  # use grep for regex
  text="abc192.168.1.1def";
  re="[0-9]{1,3}(\.[0-9]{1,3}){3}";
  ret=$(grep -Eo "$re" <<< $text)
  err=$?
  if [[ $err == 0 ]]
  then echo2 $ret;
  else echo2 "no match";
  fi

  # use sed for replacement with regex
  echo2 `sed -E 's/([^ ]+) +([^ ]+)/\2 \1/' <<< "222 111"` # output: 111 222

}

number1(){
  declare -a arr
  arr=(
    0 1 +1 -1 10 +10 -10
    077 0077 +077 -077
    0xff +0xff -0xff

    3.14 +3.14 -3.14
    3. +3. -3. 10.
    .14 +.14 -.14
    3.14E2 +3.14E2 -3.14E2
    3.14E+2 3.14E-2
    3.E2 .14E2
    0.E0 .0E0

    abc a10 10a a3.14 3.14a 3.14.15
    ff 088 0xgg
    10E2 077E2
    0E0
  )

  for i in "${arr[@]}"
  do
    if is_integer $i
    then echo2 "integer: $i + $i = $(( $i + $i ))"
    elif is_float $i
    then echo2 "float: $i + $i = `awk "BEGIN { print $i + $i }"`"
    else echo2 "err: $i"
    fi
  done
}

trim1(){
  # trim leading and trailing spaces
  a="  11  "
  b=10
  a=${a// /}  # trim
  b=${b// /}  # trim

}

file_io(){
  # read text file line by line

  # 1. file redirection
  while IFS= read -r f; do
    echo2 "file=${f}"
  done </etc/passwd

  # 2. here string
  while IFS=$'\n' read -r f; do
    echo2 "file=${f}"
  done <<< $(cat /etc/passwd)

  # 3. redirection with process substitution
  while IFS= read -r f; do
    echo2 "file=${f}"
  done < <(cat /etc/passwd)

  # 4. command substitution with pipeline
  cat /etc/passwd | while IFS= read -r f; do
    echo2 "file=${f}"
  done

  # read fields from line in text file
  while IFS=: read user_name pass user_id group_id gecos home shell
  do echo2 "$user_name, $shell"
  done < /etc/passwd

}

array_sequence1(){
  declare -a arr
  declare s x y

  s="foo bar baz"
  arr=($s)
  x=0
  y=$(( ${#arr[@]} - 1 ))

  # for in list
  for i in "${arr[@]}"
  do echo2 $i
  done

  # commas separated values
  s="foo, bar, baz"
  IFS=, read -a arr <<< "$s"
  x=0
  y=$(( ${#arr[@]} - 1 ))

  for i in "${arr[@]}"
  do echo2 $i
  done

  # range: brace expansion sequence
  for i in `eval echo {$x..$y}`
  do echo2 ${arr[$i]}
  done

}

indexed_associative_array1(){
  # indexed array
  declare -a arr=(aaa bbb ccc)
  declare -a arr2

  # echo2 "count: ${#arr[@]}, indexes/keys: ${!arr[@]}, elements: ${arr[@]}"

  arr+=(ddd eee)
  unset arr[2] # indexed array is not contiguous after element destroyed
  arr[2]="*"
  arr2=("${arr[@]}") # make a new contiguous indexed array
  for i in "${!arr2[@]}"
  do echo2 "$i: ${arr2[$i]}"
  done
  # arr=()

  # associative array
  declare -A arr3=([aaa]=10 [bbb]=20 [ccc]=30)
  arr3+=(
    [ddd]=40 [eee]=50
  )
  echo2 "${#arr3[@]}, ${!arr3[@]}, ${arr3[@]}"
  unset arr3[ccc]
  arr3[ccc]=0

  for i in "${!arr3[@]}"
  do echo2 "$i: ${arr3[$i]}"
  done
}

ansi_c_quoting(){
  # newline escape
  # with single quote and the $ prefix:
  #   $'\n'

  echo2 $'Line 1\nLine 2'  # Actual newlines
  # echo -e 'Line 1\nLine 2'   # Literal \n
  # echo -e "Line 1\nLine 2"   # Literal \n
  #
  # Line 1
  # Line 2

  echo2 'Line 1\nLine 2'   # Literal \n
  # Line 1\nLine 2
}

sort1(){
  # sort with specified field
  echo -e "3:aaa\n1:bbb\n2:ccc" | sort -t':' -k1
  # 1:bbb
  # 2:ccc
  # 3:aaa

  echo -e "3:aaa\n1:bbb\n2:ccc" | sort -t':' -k2
  # 3:aaa
  # 1:bbb
  # 2:ccc

}

sort_search(){
  declare -a haystack
  declare needle index
  haystack=(20 9 10 20); needle="20";
  # haystack=(ccc aaa bbb ccc); needle="ccc";

  # use newline as IFS for array expansion to comply with sort, grep commands
  IFS=$'\n' haystack=(`sort -n <<< ${haystack[*]}`)
  IFS=$'\n' haystack=(`grep -n $needle <<< ${haystack[*]}`)

  # or combine sort and grep in one line
  # IFS=$'\n' haystack=(`sort -n <<< ${haystack[*]} | grep -n "$needle"`)

  echo2 ${#haystack[@]}

  for i in "${haystack[@]}"
  do
    # IFS=: read index needle2 <<< $i
    index=`sed -E 's/([^:]+):([^:]+)/\1/' <<< $i`
    index=$(( $index - 1 ))
    echo2 $index
  done

}

# add leading zeros to the parameter with fewer digits
# only handles natural number with no signs -/+
# input:    9 100
# output: 009 100
align_numbers() {
  declare a="$1" b="$2"
  ! is_integer "$a" || ! is_integer "$b" && { echo "$a $b"; return ; }
  if ((${#a} < ${#b})); then
    printf -v a "%0${#b}d" "$a"
  elif ((${#b} < ${#a})); then
    printf -v b "%0${#a}d" "$b"
  fi
  echo "$a $b"
}

#

main()
{
  : # empty statement
  # echo2 "hello"

  #


}

#

# regex1
# number1
# trim1
# file_io
# array_sequence1
# indexed_associative_array1
# ansi_c_quoting
# sort1
# sort_search

main
