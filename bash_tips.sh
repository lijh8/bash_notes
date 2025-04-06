#!/bin/bash

set -u # report undefined or unbound variable

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
    # source another script and call function defined in that script
    # . foo.sh
    # source foo.sh
    # foo

    #---

    # local:
    # use local for variable inside function to avoid polluting caller scope;
    # use local or declare with -a, -A for array inside function;
    # use declare with -a, -A for array outside function;
    # do not combine local and initialization: local name=abc; # no ;
    # use local and assignment separately: local name; name=abc; # ok ;
    #
    # arithmetic:
    # use ((, )) for integer arithmetic, it supports decimal, octal, hexadecimal ;
    # use awk for floating point arithmetic, it supports scientific notation ;
    #
    # conditional comparison:
    # use [[, ]] for conditional comparison, it supports regex with =~ ;
    # do not use the test command;
    #
    # spaces:
    # 1. no spaces around assignment operator: var=value;
    #   - assignment is shell syntax and it is not command,
    #   - with spaces it will be wrongly parsed as command;
    #
    # 2. no spaces around redirection operator:
    #   cmd 2>/dev/null
    #   cmd >/dev/null 2>&1
    #
    # 3. spaces are required around operators and operands for:
    #   builtin [, [[, test command, expr command,
    #   because the operators and operands are arguments to these commands;
    #
    # escape:
    #   if test command is used instead of [[, ]] for conditional comparison,
    #   it should escape \<, \>  , or they are redirection;

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
    echo2 "$bar"

    #---

    # no space around redirection operator 2>
    local file
    # file=$0
    file="non-existent-file.txt"
    # ls "$file"               && echo2 "$file exists" || echo2 "$file not exist"
    # ls "$file" 2>/dev/null     && echo2 "$file exists" || echo2 "$file not exist"
    # ls "$file" >/dev/null 2>&1 && echo2 "$file exists" || echo2 "$file not exist"

    #---

    # { list; }
    # list of group command must be terminated with newline or semicolon;
    # spaces needed around list to separate it from braces;

    { echo2; }

    {
        echo2
    }

    #---

    # 1. use builtin [[, ]] for conditional comparison:
    #   string comparison: = != < > ;
    #   integer comparison: -eq -ne -lt -gt ;
    #   logical and , or , not :  && , || , ! ;

    local a b
    a=abc; b=abc; # string
    # a=10; b=10; # it can be used as string too

    [[ $a = $b ]]; c=$?; echo2 $c
    [[ $a != $b ]]; c=$?; echo2 $c
    [[ $a < $b ]]; c=$?; echo2 $c
    [[ $a > $b ]]; c=$?; echo2 $c
    [[ $a < $b || $a = $b ]]; c=$?; echo2 $c
    [[ $a > $b || $a = $b ]]; c=$?; echo2 $c

    a=10; b=10;   # integer

    [[ $a -eq $b ]]; c=$?; echo2 $c
    [[ $a -ne $b ]]; c=$?; echo2 $c
    [[ $a -lt $b ]]; c=$?; echo2 $c
    [[ $a -gt $b ]]; c=$?; echo2 $c
    [[ $a -le $b ]]; c=$?; echo2 $c
    [[ $a -ge $b ]]; c=$?; echo2 $c

    # 2. use (( , )) for integer arithmetic which support decimal, octal, hexadecimal ;
    # 3. do not use expr, awk, bc for integer arithmetic;
    # 4. use awk for floating point arithmetic which support scientific notation;
    # 5. do no use bc for floating point which does not support scientific and leading + , eg +3.14 ;
    # 6. use [[, ]] for conditional comparison, it supports regex with =~ ;
    #
    # string supports concatenation but not addition: c="$a $b";
    #

    local a b c err
    a=10; b=20;
    # a=10; b=-10;
    # a=10; b=3.14;
    # a=10; b=abc20;
    # a=10; b=20abc;
    c=$(( $a + $b ))
    err=$?
    [[ $err -eq 0 ]] && echo2 "ok:$err: $a + $b = $c" || echo2 "err:$err: $a + $b = $c"

    if [[ $err -eq 0 ]]
    then
        echo2 "ok:$err: $a + $b = $c"
    else
        echo2 "err:$err: $a + $b = $c"
    fi

    a=10; b=20;    c=$(( $a + $b )); err=$?; echo2 $err, $c
    a=10; b=-10;   c=$(( $a + $b )); err=$?; echo2 $err, $c
    # a=10; b=3.14;  c=$(( $a + $b )); err=$?; echo2 $err, $c # error token is ".14 "
    # a=10; b=abc10; c=$(( $a + $b )); err=$?; echo2 $err, $c # abc10: unbound variable

    a=10; b=10;    [[ $a -eq $b ]]; err=$?; echo2 $err: $a, $b
    a=10; b=20;    [[ $a -eq $b ]]; err=$?; echo2 $err: $a, $b
    # a=10; b=3.14;  [[ $a -eq $b ]]; err=$?; echo2 $err: $a, $b # error token is ".14"
    # a=10; b=abc10; [[ $a -eq $b ]]; err=$?; echo2 $err: $a, $b # unbound variable

    a="abc"; b="abc2";
    [[ $a = $b ]]; c=$?; echo2 $c
    [[ $a != $b ]]; c=$?; echo2 $c
    [[ $a > $b ]]; c=$?; echo2 $c
    [[ $a < $b ]]; c=$?; echo2 $c

    # treat it as string,
    # quotation only needed if value contains spaces or special characters: "abc efg"
    a="10"; b=10;
    [[ $a = $b ]]; c=$?; echo2 $c
    [[ $a != $b ]]; c=$?; echo2 $c
    [[ $a > $b ]]; c=$?; echo2 $c
    [[ $a < $b ]]; c=$?; echo2 $c

    #---

}

integer_arithmetic(){

    # 1. use ((, )) for integer arithmetic,
    #    it supports decimal, octal, hexadecimal:
    #    variable defaults to 0 if undefined;
    echo2 $((   10   + 3 ))                   # ok, 10, 077, 0xff;
    echo2 $((   077  + 3 ))                   # ok, 10, 077, 0xff;
    echo2 $((   0xff + 3 ))                   # ok, 10, 077, 0xff;

    # dollar $ sign is optional for variable inside (( , )) ;
    # a10=123;
    # echo2 $(( $a10  + 3 ))                  # unbound variable
    # echo2 $((  a10  + 3 ))                  # unbound variable

    # bc, expr, awk, do not support octal, hexadecimal:
    echo2 `bc <<< " ibase=8; 077 + 3 " `      # require input base (ibase);
    echo2 `expr 077 + 3 `                     # no
    echo2 `awk " BEGIN { print 077 + 3 } " `  # no


    # 2. use [[, ]] for conditional comparison test,
    #    variable defaults to 0 or "" empty null string if undefined.
    #    dollar $ sign is required for variable inside [[ ]] ;
    # a10="10";
    # [[ $a10 = "" ]] && echo2 "undefined" || echo2 $a10 # unbound variable

    # dollar $ sign is required for variable inside [[ ]] ;
    # a10=10;
    # [[ $a10 -eq 0 ]] && echo2 "undefined" || echo2 $a10 # unbound variable


    # 3. a10, used without $ , not a variable but unquoted string literal;
    #   $a10, used with $ , a variable expansion;
    #    10a, not string, not number, and variable name starts with letter a underline;
    #
    # a10=10;
    echo2 `awk " BEGIN { print a10 + 3 } " `    # awk's own variable, defaults to 0;
    echo2 `bc <<< " a10 + 3 " `                 # bc's own variable, defaults to 0;
    # echo2 `expr a10 + 3 `                     # string literal, error reported ;

    # echo2 `awk " BEGIN { print $a10 + 3 } " ` # unbound variable
    # echo2 `bc <<< " $a10 + 3 " `              # error reported
    # echo2 `expr $a10 + 3 `                    # unbound variable

    # echo2 $(( 10a + 3 ))                      # error reported
    # echo2 `bc <<< " 10a + 3 " `               # error reported
    # echo2 `expr 10a + 3 `                     # error reported
    echo2 `awk " BEGIN { print 10a + 3 } " `    # wrong, no error reported

}

regex1(){

    # [[, ]] with =~ for regex

    # should use parentheses for capture group with =~ in [[, ]];
    # ${BASH_REMATCH[0]} matches entire regular ;
    # ${BASH_REMATCH[1]} and rest match parenthesized capture group;

    # get the numbers like ` grep -o ` ;
    a="aaa 100 bbb 200 ccc"
    b='^[a-z]+[ ]+([0-9]+)[ ]+[a-z]+[ ]+([0-9]+)[ ]+[a-z]+$'
    if [[ $a =~ $b ]]
    then
        for i in ${BASH_REMATCH[@]:1} # ${parameter:offset} expansion
        do
            echo2 "$i"
        done
    fi


    # use sed for regex replacement
    echo2 `sed -E 's/([^ ]+) +([^ ]+)/\2 \1/' <<< "222 111"` # output: 111 222


    # use grep for regex
    local a b c
    a="abc192.168.1.1def";
    b="[0-9]{1,3}(\.[0-9]{1,3}){3}";
    c=`grep -Eo "$b" <<< $a`
    if [[ $? == 0 ]]
    then
        echo2 $c;
    else
        echo2 "no match";
    fi
}

# check if a value is an integer number.
is_integer() {
    # 10, 20,
    [[ $1 =~ ^[+-]?[0-9]+$ ]]
}

# check if a value is an integer or floating-point number.
is_numeric(){
    # 10, 3.14,
    [[ $1 =~ ^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)$ ]]
}

# check if a value is an integer or floating-point number with scientific notation support.
is_scientific(){
    # 10, 3.14, 10E2, 3.14E2,
    [[ $1 =~ ^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$ ]]
}

number1(){

    # use ((, )) for integer arithmetic
    # use awk command for floating point arithmetic;
    # check if operands are numeric before using awk;
    #
    # bc command does not support + sign, eg. +3.14, 3.14E+2;
    # bc command does not support scientific notation 3.14E2 ;
    # the builtin (( does not support floating point;

    local a b c err
    local -a arr
    a=10
    # is_integer $a && echo2 "$a is integer" || echo2 "$a is not integer"

    arr=(
    "10" "+10" "-10"
    "3.14" "+3.14" "-3.14"
    "3." "+3." "-3."
    ".14" "+.14" "-.14"
    "" " " "." "12a" "a12" "3.14.5"
    )

    for val in "${arr[@]}"
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
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; err=$?; echo2 $err, $c; }
    a=10; b=20;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; err=$?; echo2 $err, $c; }
    c=$(( $a + $b )); err=$?; echo2 $err, $c;

    a=a3.14; b=5;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; err=$?; echo2 $err, $c; }
    a=3.14a; b=5;
    is_numeric $a && is_numeric $b && { c=`awk "BEGIN {print $a + $b}"`; err=$?; echo2 $err, $c; }

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
    y=$(( ${#arr[@]} - 1 ))

    # for in list
    for i in "${arr[@]}"
    do
        echo2 $i
    done

    # commas separated values
    s="foo, bar, baz"
    IFS=, read -a arr <<< "$s"
    x=0
    y=$(( ${#arr[@]} - 1 ))

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
    local -a haystack
    local needle index
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


#

# main
integer_arithmetic
# regex1
# number1
# file_io
# array_and_sequence
# newline_escape
# sort1
# sort_search
