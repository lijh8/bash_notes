# echo
echo with source location

```
$ cat main.sh
echo2(){
  echo "`caller | sed -E 's/([^ ]+) +([^ ]+)/\2:\1/'`: $*"
}
echo2 "hello"
$

$ bash main.sh
main.sh:10: hello
$
```
