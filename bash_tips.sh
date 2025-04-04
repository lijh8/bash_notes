#!/bin/bash

# ShellCheck, a static analysis tool for shell scripts ,
# https://github.com/koalaman/shellcheck ,
# also recommended by Google Shell Style Guide ,
# $ apt install shellcheck
# $ shellcheck hello.sh

# echo with source location.
echo2(){
    echo "`caller | sed -E 's/([^ ]+) +([^ ]+)/\2:\1/'`: $*"
}

# or using an alias
shopt -s expand_aliases
alias echo3='echo "${BASH_SOURCE[0]}:${LINENO}:${FUNCNAME[0]}:"'

# echo2 "hello"
# echo3 "hello"

main()
{
    # source another script and call function in that script
    . foo.sh
    source foo.sh
    foo

    #---

    #
    # use local for variable inside function to avoid polluting caller scope;
    # use local or declare with -a, -A for array inside function;
    # use declare with -a, -A for array outside function;
    # do not combine local and initialization: local name=abc; # no ;
    # use local and assignment separately: local name; name=abc; # ok ;
    #
    # expr command, test builtin command, [, [[,
    #   - spaces required around operators and operands,
    #   - because expr, test are commands,
    #   - their operators and operands are arguments to these commands;
    #
    # no spaces around assignment operator: var=value;
    #   - assignment is shell syntax and it is not command,
    #   - with spaces it will be wrongly parsed as command;
    #
    # no spaces around redirection operator:
    #   cmd 2>/dev/null
    #   cmd >/dev/null 2>&1
    #

    local name
    name=abc

    #---

    # quote variables or values for they could have spaces or special characters;
    # variable parameter expansion $ , backtick ` , escape \ , work in double quoting;
    local foo bar
    foo='abc 123'
    foo="abc 123"
    bar="$foo"
    bar="`date`"
    bar="dollar: \$10"
    echo "$bar"

    #---

    # no space around redirection operator 2>
    local file
    # file=$0
    file="non-existent-test-file.txt"
    # ls "$file"               && echo "$file exists" || echo "$file not exist"
    ls "$file" 2>/dev/null     && echo "$file exists" || echo "$file not exist"
    ls "$file" >/dev/null 2>&1 && echo "$file exists" || echo "$file not exist"

    #---

    # { list; }
    # list of group command must be terminated with newline or semicolon;
    # spaces needed around list to separate it from braces;

    { echo; }

    {
        echo
    }

    #---

    #
    # 1. use test builtin for conditional expression:
    #   string comparison: = != < > ; escape \<, \>, or they are redirection;
    #   integer comparison: -eq -ne -le -lt -ge -gt ;
    #       a="abc"; b="abc";
    #       test $a = $b; c=$?; echo $c
    #       test $a != $b; c=$?; echo $c
    #       test $a \< $b; c=$?; echo $c # escape
    #       test $a \> $b; c=$?; echo $c
    #
    #       a=10; b=20;
    #       test $a -eq $b; c=$?; echo $c
    #       test $a -ne $b; c=$?; echo $c
    #       test $a -lt $b; c=$?; echo $c
    #       test $a -le $b; c=$?; echo $c
    #       test $a -gt $b; c=$?; echo $c
    #       test $a -ge $b; c=$?; echo $c
    #
    # 2. use expr command for integer arithmetic, with exit status 2, 3 for error;
    # 3. use grep command for regex;
    #
    # test builtin returns a status of 0 (true) or 1 (false);
    # expr command prints the value to standard output, and returns exit status;
    #
    # string supports concatenation but not addition: c="$a $b";
    #
    # do not use bc, (( for arithmetic;
    #  - for bc does not indicate error with exit status;
    #  - for (( aborts on error;
    #
    # -a , logical and ;
    # -o , logical or ;

    local a b c err
    a=10; b=20;
    # a=10; b=-10;
    # a=10; b=3.14;
    # a=10; b=abc20;
    c=`expr $a + $b 2>/dev/null`
    err=$?
    test $err -eq 2 -o $err -eq 3 && echo "error:$err: $a + $b" || echo "ok:$err: $c"

    if test $err -eq 2 -o $err -eq 3
    then
        echo "error:$err: $a + $b"
    else
        echo "ok:$err: $c"
    fi

    a=10; b=20;    c=`expr $a + $b`;             err=$?; echo $err, $c
    a=10; b=-10;   c=`expr $a + $b`;             err=$?; echo $err, $c
    a=10; b=3.14;  c=`expr $a + $b 2>/dev/null`; err=$?; echo $err, $c
    a=10; b=abc10; c=`expr $a + $b 2>/dev/null`; err=$?; echo $err, $c

    a=10; b=10;    test $a -eq $b;               err=$?; echo $err: $a, $b
    a=10; b=20;    test $a -eq $b;               err=$?; echo $err: $a, $b
    a=10; b=3.14;  test $a -eq $b 2>/dev/null;   err=$?; echo $err: $a, $b
    a=10; b=abc10; test $a -eq $b 2>/dev/null;   err=$?; echo $err: $a, $b

    a="abc"; b="abc2";
    test $a = $b; c=$?; echo $c
    test $a != $b; c=$?; echo $c
    test $a \> $b; c=$?; echo $c
    test $a \< $b; c=$?; echo $c

    # treat it as string,
    # quotation only needed if value contains spaces or special characters: "abc efg"
    a="10"; b=10;
    test $a = $b; c=$?; echo $c
    test $a != $b; c=$?; echo $c
    test $a \> $b; c=$?; echo $c
    test $a \< $b; c=$?; echo $c

    #---

}

regex_test(){
    # ue grep for regex
    local a b c
    a="abc192.168.1.1def";
    b="\d{1,3}(\.\d{1,3}){3}"; # grep regex engine
    c=`grep -Eo "$b" <<< $a`
    if (( $? == 0 )); then
        echo $c;
    else
        echo "no match";
    fi

    # use sed for regex replacement
    echo "`caller | sed -E 's/([^ ]+) +([^ ]+)/\2:\1/'`: $*"

}

is_integer() {
    grep -Eq '^[+-]?[0-9]+$' <<< $1
}

# check if a value is either integer or floating point
is_numeric(){
    grep -Eq '^[+-]?([0-9]+\.?|[0-9]*\.?[0-9]+)$' <<< "$1"
}

number_test(){
    # use expr command for integer arithmetic
    local a b c ret
    a=10
    # is_integer $a && echo2 "$a is integer" || echo2 "$a is not integer"

    #
    # use awk command for floating point arithmetic;
    # check if operands are numeric before awk;
    #
    # bc command does not support leading + , eg. +3.14;
    # the builtin (( does not support floating point;
    # use expr command for integer arithmetic
    #

    # Test inputs
    test_values=(
    "10" "+10" "-10"
    "3.14" "+3.14" "-3.14"
    "3." "+3." "-3."
    ".14" "+.14" "-.14"
    "" " " "." "12a" "a12" "3.14.5"
    )

    for val in "${test_values[@]}"
    do
        if is_numeric "$val"
        then
            echo2 "✅ Valid: \"$val\""
        else
            echo2 "❌ Invalid: \"$val\""
        fi
    done

    #
    a=+3.; b=-.14;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; ret=$?; echo2 $ret, $c; }
    a=10; b=20;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; ret=$?; echo2 $ret, $c; }
    c=`expr $a + $b`; ret=$?; echo2 $ret, $c;

    a=a3.14; b=5;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; ret=$?; echo2 $ret, $c; }
    a=3.14a; b=5;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; ret=$?; echo2 $ret, $c; }

}

trim(){
    # trim leading and trailing spaces
    a="  11  "
    b=10
    a=${a// /}  # trim
    b=${b// /}  # trim

}

file_io(){
    # read text file line by line
    while IFS= read line
    do
        echo2 $line
    done < /etc/passwd

    # read fields in a line of text file
    while IFS=: read user_name pass user_id group_id gecos home shell
    do
        echo2 "$user_name, $shell"
    done < /etc/passwd

}

array_and_sequence(){
    local -a arr
    local s x y

    s="foo bar baz"
    arr=($s)
    x=0
    y=`expr ${#arr[@]} - 1`

    # for in list
    for i in "${arr[@]}"
    do
        echo2 $i
    done

    # commas separated values
    s="foo, bar, baz"
    IFS=, read -a arr <<< "$s"
    x=0
    y=`expr ${#arr[@]} - 1`

    for i in "${arr[@]}"
    do
        echo2 $i
    done

    # brace expansion sequence
    for i in `eval echo {$x..$y}`
    do
        echo2 ${arr[$i]}
    done

}

newline_escape(){
    # with single quote and the $ prefix:
    #   $'\n'

    echo $'Line 1\nLine 2'  # Actual newlines
    # echo -e 'Line 1\nLine 2'   # Literal \n
    # echo -e "Line 1\nLine 2"   # Literal \n
    #
    # Line 1
    # Line 2

    echo 'Line 1\nLine 2'   # Literal \n
    # Line 1\nLine 2
}

sort_test(){
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
    local -a haystack
    local needle index
    haystack=(333 111 222 333); needle="333";
    # haystack=(ccc aaa bbb ccc); needle="ccc";

    # sort and search
    # use newline as IFS for array expansion to comply with sort command
    IFS=$'\n' haystack=( `sort -n <<< ${haystack[*]} | grep -n $needle` )

    # or replace space with newline using parameter expansion
    # IFS=$'\n' haystack=( `sort -n <<< ${haystack[*]// /$'\n'} | grep -n $needle` )

    echo2 ${#haystack[@]}

    for i in "${haystack[@]}"
    do
        # IFS=: read index needle2 <<< $i
        index=`sed -E 's/([^:]+):([^:]+)/\1/' <<< $i`
        index=`expr $index - 1`
        echo2 $index
    done

}


#

# main
# number_test
# file_io
# array_and_sequence
# newline_escape
# sort_test
sort_search
