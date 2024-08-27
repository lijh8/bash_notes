#!/bin/bash

. echo.sh

# no space around = assignment
#   a=b

# need spaces for test around [[ and ]] and around operands
#   if [[  $a  ==  $b  ]];


#---


is_integer() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}

is_numeric() {
    [[ $1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
}


integer=10
float=20.5

is_integer $integer && echo true || echo false
is_integer $float && echo true || echo false
is_numeric $integer && echo true || echo false
is_numeric $float && echo true || echo false

# Calculate the sum using awk
sum=$(awk "BEGIN {print $integer + $float}")
echo $sum


#---


string_test(){
    # [[, ]] for string
    # no <=, >=, use || logical operator

    # comparison
    a="abc" # no space around = operator
    b="abc"
    if [[ $a == $b ]]; then echo "$a == $b" # need spaces around [[ and ]]
    elif [[ $a < $b ]]; then echo "$a < $b"
    elif [[ $a > $b ]]; then echo "$a > $b"; fi

    if [[ $a != $b ]]; then echo "$a != $b"; fi
    if [[ $a < $b || $a == $b ]]; then echo "$a <= $b"; fi
    if [[ $a > $b || $a == $b ]]; then echo "$a >= $b"; fi

    #
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

    # trim spaces
    a="  11  "
    b=10
    a=${a// /}  # trim
    b=${b// /}  # trim
    echo $(( a > b ))
    echo $(( a < b ))
    echo $(( a == b ))

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
