#!/bin/bash

# no space around = assignment
#   a=b

# need spaces for test after [[ , before ]], and around operands
#   if [[  $a  ==  $b  ]];

shopt -s expand_aliases
alias echo='echo "$BASH_SOURCE:$LINENO":$FUNCNAME: '

string_test(){
    # [[, ]] for string
    # no <=, >=, use || logical operator

    # comparison
    a="abc" # no space around = operator
    b="abc"
    if [[ $a == $b ]]; then echo "$a == $b" # need spaces in [[, ]]
    elif [[ $a < $b ]]; then echo "$a < $b"
    elif [[ $a > $b ]]; then echo "$a > $b"; fi

    if [[ $a != $b ]]; then echo "$a != $b"; fi
    if [[ $a < $b || $a == $b ]]; then echo "$a <= $b"; fi
    if [[ $a > $b || $a == $b ]]; then echo "$a >= $b"; fi
}

number_test(){
    # ((, )) for number

    # comparison
    a=7
    b=3
    if (( a == b )); then echo "$a == $b"
    elif (( a < b )); then echo "$a < $b"
    elif (( a > b )); then echo "$a > $b"; fi

    if (( a != b )); then echo "$a != $b"; fi
    if (( a <= b )); then echo "$a <= $b"; fi
    if (( a >= b )); then echo "$a >= $b"; fi

    if (( a < b || a == b )); then echo "$a <= $b"; fi
    if (( a > b || a == b )); then echo "$a >= $b"; fi

    # arithmetic
    c=$(( a + b )); echo "$a + $b = $c"
    c=$(( a - b )); echo "$a - $b = $c"
    c=$(( a * b )); echo "$a * $b = $c"
    c=$(( a / b )); echo "$a / $b = $c"
    c=$(( a % b )); echo "$a % $b = $c"
}

regex_test(){
    # regex
    # use sed to do replacement for match

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

string_test
number_test
regex_test
