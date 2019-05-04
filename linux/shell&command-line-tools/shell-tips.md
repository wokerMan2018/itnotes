- 获取当前发行版信息

  ```shell
  echo $(. /etc/os-release;echo $NAME)
  ```
  
- 获取任意用户家目录路径

  ```shell
  username=`whoami`  #用户名
   grep ^$username: /etc/passwd |cut -d ":" -f 6
  ```

- 获取当前软链接的路径

  ```shell
  readlink -f `dirname $0`
  ```

- 获取文件大小

  ```shell
  stat --format=%s <filename>  #单位为byte
  ```

- 打开默认应用 `xdg-open <file or url>`

  ```shell
  xdg-open http://localhost #使用默认浏览器访问http://localhost
  xdg-open testfile  #使用默认编辑器打开testfile文件
  ```

- 临时文件

  ```shell
  testfile=$(mktemp)
  echo "test test" > $testfile
  cat $testfile  #test test
  ```

  