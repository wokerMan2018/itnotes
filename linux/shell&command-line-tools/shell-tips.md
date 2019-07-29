- install和cp

  一些程序安装脚本以及Makefile里会用到install进行文件复制，它与cp主要区别：

  - 如果目标文件存在，cp会先清空文件后往里写入新文件，而install则会先删除掉原先的文件然后写入新文件

    这是因为往正在使用的文件中写入内容可能会导致一些问题，比如写入正在执行的文件可能会失败，已经在持续写入的文件句柄中写入新文件会产生错误的文件。使用  install先删除后写入（会生成新的文件句柄）的方式去安装就能避免这些问题

  - install命令会恰当地处理文件权限的问题。

    - `install -c a /path/to/b`  把目标文件b的权限设置为`-rwxr-xr-x`
    - `install -m0644  a /path/to/b`  把目标文件b的权限设置为`-rw-r--r--`

  - install命令可以打印出更多更合适的debug信息，还会自动处理SElinux上下文的问题。

- shell文件格式化工具`shfmt`

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

- 获取当前执行文件所在的目录

  ```shell
  path=$(dirname $(readlink -f "$0"))
  ```

  或

  ```shell
  path=$(cd $(dirname $0) ; pwd)
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

- 杀死一个进程以及其所有后代进程

  ```shell
  pid=1234  #1234是进程号
  [[ $pid ]] && kill -9 $(pstree $pid -p|grep -oE "\([0-9]+\)"|grep -oE "[0-9]+")
  ```

- 获取当前终端端宽（列数）高（行数）

  - 全局变量`COLUMNS`和`LINES`
  - `tput cols`和`tput lines`
  - `stty size`  (输出两个数字，以空格分开，前面为行数--高，后面为列数-宽）

- 重复输出一个字符

  - 使用printf

    ```shell
    #打印30个*
    s=$(printf "%-30s" "*")
    echo -e "${s// /*}"
    
    #根据当前终端宽度（列数）打印一整行=
    
    #使用sed
    printf "%-${COLUMNS}s" "="|sed "s/ /=/g"
    
    #使用echo
    s=$(printf "%${COLUMNS}s" "=")
    echo -e "${s// /=}"
    ```

  - 使用seq

    根据当前终端宽度（列数）打印一整行`=`：

    ```shell
     seq -s "=" $(({COLUMNS}+1))|sed -E "s/[0-9]//g"
    ```

    seq以`=`为分隔符生成与终端宽度字符数量相等的数字（形如`1=2=3=4`）

    sed正则匹配所有数字并替换为空字符串。（`=`总比数字少1个，因此要行数基础上+1，这样再将数字去掉后`=`数量才和一行字符数量一致）

- gzexe给脚本加密（普通文件亦可）

  ```shell
  gzexe a.sh
  ```

   例如给a.sh加密，该命令执行完成后将有两份文件，`a.sh`和`a.sh~`，带`~`的是原来的文件，不带`~`的是加密过的文件。

- 脚本修改密码

  - passwd的`--stdin`参数（某些发行版的passwd可能不支持）

    ```shell
    echo "new_pwd" | passwd --stdin [username]
    ```

  - chpasswd 读取文件

    创建一个含有用户名和密码的文件，每行一个用户信息，使用`:`分隔用户名和密码，形如`username:password`，例如该文件为`/tmp/pwds`，内容为：

    ```txt
    root:123456
    user1:123456
    ```

    使用chpasswd读取该文件：

    ```shell
    chpasswd < /tmp/pwds
    ```

    