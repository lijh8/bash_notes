# echo
echo with source location

```
$ sh main.sh
echo.sh:9:: echo with source location
main.sh:14:: hello world
main.sh:10:hello: hello function
$

$ bash main.sh
echo.sh:9:: echo with source location
main.sh:14:: hello world
main.sh:10:hello: hello function
$

$ bash src/main/a.sh
src/main/a.sh:17:main: aaa 10
src/main/a.sh:10:foo: foo
src/main/b.sh:11:bar: bar
$
```
