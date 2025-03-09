#!/bin/bash

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO:$FUNCNAME:"'


#---


cmd_exit_status_condition(){
    local filename
    filename=$0
    # filename="non-existent-test-file.txt"
    # filename="rm non-existent-test-file.txt"  # test dangerous cmd from user input

    # without if
    ls "$filename" > /dev/null 2>&1 && echo "$filename exists" || echo "$filename not exist"

    # with if
    if ls "$filenamze" > /dev/null 2>&1
    then
        echo "$filename exists"
    else
        echo "$filename not exist"
    fi

    # or check exit status with special parameter $? ,
    ls "$filename" > /dev/null 2>&1
    if expr $? = 0 > /dev/null 2>&1
    then
        echo "$filename exists"
    else
        echo "$filename not exist"
    fi
}

cmd_exit_status_condition


#---


check_user_input_test(){
    local user_input output exit_status
    user_input="ls $0"
    # user_input="rm tmp_important_file_abc_123_test.txt"  # test

    # CAUTION! it actually tries to rm the file in command substitution,
    # rm: cannot remove 'tmp_important_file_abc_123_test.txt': No such file or directory
    #
    # command substitute, `cmd`, $(cmd) ,
    # output=`$user_input > /dev/null 2>&1`
    output=`$user_input`
    exit_status=$?
    expr $exit_status = 0 > /dev/null 2>&1 && echo "ok" || echo "error"
    test $exit_status -eq 0 && echo "ok" || echo "error"

    # CAUTION! it actually tries to rm the file in eval,
    # rm: cannot remove 'tmp_important_file_abc_123_test.txt': No such file or directory
    #
    # eval,
    # output=`eval $user_input > /dev/null 2>&1`
    output=`eval $user_input`
    exit_status=$?
    expr $exit_status = 0 > /dev/null 2>&1 && echo "ok" || echo "error"
    test $exit_status -eq 0 && echo "ok" || echo "error"

}

check_user_input_test


#---


# https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html ,
# If a numeric argument is given to return, that is the function’s return status;
# otherwise the function’s return status is the exit status of the last command executed before the return.

is_integer() {
    grep -Eq "^[+-]?[0-9]+$" <<< $1
}

is_numeric() {
    grep -Eq "^[+-]?[0-9]*\.?[0-9]+$" <<< $1
}

test_integer_numeric(){
    local integer1 float1
    integer1=10
    float1=20.5

    is_integer $integer1 && echo true || echo false
    is_integer $float1 && echo true || echo false
    is_numeric $integer1 && echo true || echo false
    is_numeric $float1 && echo true || echo false

}

test_integer_numeric


#---


# 1. no space around = assignment operator;
#       a=b
#
# 2. variables inside function should be declared as local,
#   otherwise, they are global variables and pollute the caller scope;
#
# 3. do not combine local declaration and initialization together,
#   local declare first, then do assignment, they should be in two separate statements;
#
# 4. use expr command for string comparision, integer comparison and arithmetic,
#   it can indicate error with non-zero exit status;
#
# 5. escape >, <, * in expr, or they are regarded as output, input redirection, wildcard globbing;
#
# 6. the test command also works for string comparison and integer comparisio,
#   escape >, < in test command, or they are regarded as output, input redirection,
#   the test command also works for file test;
#   but test command does not work for integer arithmetic;
#   use test command instead of [ , [[ ;
#
# 7. if one operand is number and the other is string, the number is regarded as string too;
#
# 8. the expr does not support regex of ERE, use grep -Eoi instead;
#
# 9. do not use ((, bc, awk, even if there is floating point number;
# - do not use (( for arithmetic, it aborts if operand is not a number;
# - do not use bc for arithmetic, it outputs error but exit status is still zero if operand is not a number;
# - do not use awk for arithmetic, it quietly fails if operand is not a number;

number_string_with_expr(){
    # ((, )) for number

    # comparison
    local a b c filename
    a=7  # integer: 7, or string: abc7a
    b=3a  # integer: 3, or string: abc3a
    filename=$0

    # expr command
    # if both operands are numbers, it does integer comparison or integer arithmetic,
    # or if one of the operands is string, it does string comparison.
    expr $a \> $b > /dev/null 2>&1 && echo "$a > $b" || echo "error: $a > $b"  # escape >, <, *
    expr $a \< $b > /dev/null 2>&1 && echo "$a < $b" || echo "error: $a < $b"  # escape >, <, *
    expr $a = $b > /dev/null 2>&1 && echo "$a = $b" || echo "error: $a = $b"

    c=`expr $a + $b > /dev/null 2>&1` && echo "$c" || echo "error: $a + $b"
    c=`expr $a - $b > /dev/null 2>&1` && echo "$c" || echo "error: $a - $b"
    c=`expr $a \* $b > /dev/null 2>&1` && echo "$c" || echo "error: $a * $b"  # escape >, <, *
    c=`expr $a / $b > /dev/null 2>&1` && echo "$c" || echo "error: $a / $b"
    c=`expr $a % $b > /dev/null 2>&1` && echo "$c" || echo "error: $a % $b"

    # test command, it only does comparison,
    # for string comparison == , != , > , < , ( but no <= , >= ) , escape < , > ,
    # for integer comparison -eq , -ne , -gt , -lt , -ge , -le ,
    # for file test -e , -f , -d , -r , -w , -x , -s ,
    local a b str1 str2 filename
    a=3
    b=7
    str1="abc"
    str2="efg"

    test $str1 == $str2 && echo "$str1 == $str2" || echo "error: $str1 == $str2"
    test $str1 \< $str2 && echo "$str1 < $str2" || echo "error: $str1 < $str2"

    test $a -eq $b && echo "$a == $b" || echo "error: $a == $b"
    test $a -lt $b && echo "$a < $b" || echo "error: $a < $b"

    test -e $filename && echo "ok" || echo "error"
    test -f $filename && echo "ok" || echo "error"

}


regex_test(){
    # regex
    # use sed to do replacement for match

    local a b c
    a="abc192.168.1.1def";
    b="\d{1,3}(\.\d{1,3}){3}"; # grep regex engine
    c=`grep -Eo "$b" <<< $a`
    if (( $? == 0 )); then
        echo $c;
    else
        echo "no match";
    fi

    a="abc192.168.1.1def"
    b="[0-9]{1,3}(\.[0-9]{1,3}){3}" # bash regex engine
    if [[ $a =~ $b ]]; then
        echo "${BASH_REMATCH[0]}"
    else
        echo "no match"
    fi

    a="tobeornottobe";
    b="(to)(be)ornot\1\2";
    c=`grep -Eo "$b" <<< $a`

    if (( $? == 0 )); then
        echo $c;
    else
        echo "no match";
    fi

    a=123
    # a=-23
    # a=abc
    if ! [[ "$a" =~ ^[0-9]+$ ]] || (( a < 0 )); then
        echo "non positive number: $a"
    else
        echo "positive number: $a"
    fi

}


# string and array

string_array_test(){
    local string1 array1
    string1=abc
    array1=()
    for (( i=0; i!="${#string1}"; i++ )); do
        local c="${string1:$i:1}"
        # array1[$i]="$c" # ok
        array1+=("$c") # ok, parentheses needed
        echo $c
    done
    echo "${array1[@]}"

    local string1=""
    echo $string1
    for e in "${array1[@]}"; do
        string1+="$e"
        echo $e
    done
    echo $string1
}


trim_test(){

    # trim leading trailing spaces
    a="  11  "
    b=10
    a=${a// /}  # trim
    b=${b// /}  # trim

}


number_string_with_expr
regex_test
string_array_test
trim_test




#---
#---
#---




# old test below, not recommended.

number_string_test_old(){
    # comparison
    # local a b c
    # a=7  # integer: 7, or string: abc7a
    # b=3a  # integer: 3, or string: abc3a

    # need spaces for test around [[ and ]] and around operands
    #   if [[  $a  ==  $b  ]];

    # if (( a == b )); then echo "$a == $b"
    # elif (( a < b )); then echo "$a < $b"
    # elif (( a > b )); then echo "$a > $b"; fi

    # if (( a != b )); then echo "$a != $b"; fi
    # if (( a <= b )); then echo "$a <= $b"; fi
    # if (( a >= b )); then echo "$a >= $b"; fi

    # if (( a < b || a == b )); then echo "$a <= $b"; fi
    # if (( a > b || a == b )); then echo "$a >= $b"; fi

    # arithmetic
    # c=$(( a + b )); echo "$a + $b = $c"
    # c=$(( a - b )); echo "$a - $b = $c"
    # c=$(( a * b )); echo "$a * $b = $c"
    # c=$(( a / b )); echo "$a / $b = $c"
    # c=$(( a % b )); echo "$a % $b = $c"

    # echo $(( a > b ))
    # echo $(( a < b ))
    # echo $(( a == b ))

    :  # empty command, this suppress the error of function body being empty,
}


# old test below, not recommended.

# the expr utility works for both string comparison and integer arithmetic
# use test command instead of [ , [[ ;

string_test(){
    # [[, ]] for string
    # no <=, >=, use || logical operator

    # comparison
    local a b
    a="abc" # no space around = operator
    b="abc"
    if [[ $a == $b ]]; then echo "$a == $b" # need spaces around [[ and ]]
    elif [[ $a < $b ]]; then echo "$a < $b"
    elif [[ $a > $b ]]; then echo "$a > $b"; fi

    if [[ $a != $b ]]; then echo "$a != $b"; fi
    if [[ $a < $b || $a == $b ]]; then echo "$a <= $b"; fi
    if [[ $a > $b || $a == $b ]]; then echo "$a >= $b"; fi

    local true1 false1 c1 c2 c3
    true1="true"
    false1="false"
    c1=$([[ "$a" > "$b" ]] && printf "$true1" || printf "$false1")
    c2=$([[ "$a" < "$b" ]] && printf "$true1" || printf "$false1")
    c3=$([[ "$a" == "$b" ]] && printf "$true1" || printf "$false1")
    echo "$c1"
    echo "$c2"
    echo "$c3"

}


# old test below, not recommended.

let_test_old(){
    # let, do not use let,
    # it introduces more strange rules about spaces.

    # without quotes, no spaces around = and other operators.
    let c=a+b; echo $c
    let c=a-b; echo $c
    let c=a*b; echo $c
    let c=a/b; echo $c
    let c=a%b; echo $c

    # with quotes, spaces are allowed.
    let "c=a+b "; echo $c
    let "c=a-b"; echo $c
    let "c=a*b"; echo $c
    let "c=a/b"; echo $c
    let "c=a%b"; echo $c

}


#---

