- 临时文件mktemp

  ```shell
  testfile=$(mktemp)
  echo "test test" > $testfile
  cat $testfile  #test test
  ```

## 替换和删除

- 将换行转换为实际的`\n`字符

  示例，欲将文件file

  >line1
  >
  >line2

  变成

  >line1\nline2

  在文本中的换行符号表现为换行，示例将file文件的换行符号变成实际的`\n`符号，所有行文本归为一行：

  - sed模式空间处理

  ```shell
  #tag只是一个自定义的标记名
  sed ":tag;N;s/\n/\\\n/;b tag" file
  ```

  - 利用echo输出自动去掉换行符

    echo不使用-e时将忽略`\n`换行

    ```shell
    #$表示最后一行   $ !表示除了最后一行的行
    #行末替换成\n字符 （注意转义），再echo输出
  echo $(sed  "$ !  s/$/\\\n/" file) > file
    ```

- 删除空白行（或者说替换空白行内容为空字符）

  - tr   只打印到标准输出（可重定向保存）

    ```shell
    cat file | tr -s '\n'
    ```

  - sed  使用-i参数可以直接编辑并存储

    ```shell
    sed "/^$/d" file
    sed -i "/^$/d" file
    ```

  - awk  只打印到标准输出 （可重定向保存）

    ```shell
    awk '{if($0!="") print}' file
    awk '{if(length!=0) print $0}' file
    ```

  - grep  只打印到标准输出 （可重定向保存）

    ```shell
    grep -v "^$" file
    ```

  

  