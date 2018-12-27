以`-`开头的文件，例如-test.txt

```
ls -- -test.txt
cat -- -test.txt
ls -- ./-test.txt
```



```shell
touch {a..z}.txt  #生成a.txt、b.txt……直到z.txt
touch foo{,txt}  #生成foo和foo.txt两个文件
```

