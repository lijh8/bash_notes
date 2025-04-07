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
#
# check if a value is integer
# use ((, )) for integer arithmetic
# it supports decimal, octal, hexadecimal
# it does not support scientific notation
is_integer() {
  # 10, 20,
  re="^[+-]?([1-9][0-9]*|0[0-7]*|0[Xx][0-9A-Fa-f]+)$"
  [[ $1 =~ $re ]]
}

# is_float
#
# check if a value is a floating-point number
# with scientific notation support
# use awk for floating point arithmetic
# it does not support octal, hexadecimal
is_float(){
  # 3.14, 3.14E2,
  re="^[+-]?([0-9]+[.][0-9]*|[.][0-9]+)([Ee][+-]?[0-9]+)?$"
  [[ $1 =~ $re ]]
}

#---

# sourcing
#
# source a file and call function from it
#
#   source foo.sh
#   . foo.sh
#   foo
#   foo abc 123 # with args if needed

#---

# declare
#
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
# declare integer with -i
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
# https://google.github.io/styleguide/shellguide.html
#
#   declare name=$(cmd) # no
#   declare name=`cmd`  # no
#
#   declare name
#   name=$(cmd)         # ok
#   name=`cmd`          # ok

#---

# integer
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

# float
#
# use awk for floating point arithmetic, scientific notation supported
#
#   declare a=3.14 b
#   b=`awk "BEGIN{ print $a + $a }"`
#   echo2 $b

# string
#
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

#---

# spaces
#
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
#
#   - in test command escape \<, \>  , or they are redirection
#   - Ansi-C quoting $'\n'

#---

# quoting
#
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
#
# { list; }
# list of group command must be terminated with newline or semicolon;
# spaces needed around list to separate it from braces;
#
#   { echo2; }
#
#   {
#     echo2
#   }

#---

# examples

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
    # ${parameter:offset} expansion
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
  while IFS= read line
  do echo2 $line
  done < /etc/passwd

  # read fields in a line of text file
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

  # brace expansion sequence
  for i in `eval echo {$x..$y}`
  do echo2 ${arr[$i]}
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

main()
{
  echo2 "hello"

}

#

# regex1
# number1
# trim1
# file_io
# array_sequence1
# ansi_c_quoting
# sort1
# sort_search
main
