#!/bin/bash

# ShellCheck, a static analysis tool for shell scripts ,
# https://github.com/koalaman/shellcheck ,
# also recommended by Google Shell Style Guide ,
# $ apt install shellcheck
# $ shellcheck hello.sh

# echo with source location.

# echo using an alias
shopt -s expand_aliases
alias echo2='echo "${BASH_SOURCE[0]}:${LINENO[0]}:${FUNCNAME[0]}:"'

# or echo using a function
echo3(){
    echo "${BASH_SOURCE[1]}:${BASH_LINENO[0]}:${FUNCNAME[1]}: $*"
}

# echo2 "hello bash"
# echo3 "hello bash"

main()
{
    # source another script and call function in that script
    . foo.sh
    source foo.sh
    foo

    #---

    # use local for variable inside function to avoid polluting caller scope;
    # use local or declare with -a, -A for array inside function;
    # use declare with -a, -A for array outside function;
    # do not combine local and initialization: local name=abc; # no ;
    # use local and assignment separately: local name; name=abc; # ok ;
    # no space around assignment operator: name=abc;
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

    # test builtin returns a status of 0 (true) or 1 (false);
    # expr command prints the value to standard output, and returns exit status;
    #
    # use test builtin for conditional expression:
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
    # use expr command for integer arithmetic, with exit status 2, 3 for error;
    #
    # string supports concatenation but not addition: c="$a $b";
    #
    # do not use bc, awk, (( for arithmetic;
    #  - for bc does not indicate error with exit status;
    #  - for awk does not even show message on error;
    #  - for (( aborts on error;
    #

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

main
