# 安装

- 从yum源安装

  ```shell
  yum install epel-release  #确保已经安装epel源 pdhs位于该源中
  yum install pdsh
  ```

- 编译安装

  下载[pdsh编译](https://github.com/chaos/pdsh/releases)。常用的几个编译选项：

  ```shell
  ./configure --with-ssh --with-machines=/path/to/machines --with-timeout=N 
  --with-readline
  ```

  - `--with-ssh`  ssh服务支持

  - `-- --with-machines`  主机列表文件路径

    在该文件中写入主机地址（或主机名——需要在hosts中写好主机解析），每行一个。

    存在machines文件，使用`pdsh`执行时若不指定主机，则默认对machines文件中所有主机执行该命令。

  - `--with-timeout`  超时，默认10s

  - `--with-readline`  支持交互模式输入

  具体可参看[文档](https://github.com/chaos/pdsh)。

# 使用

常用参数：

- `-w` 指定目标主机

  目标主机可以使用Ip地址或主机名（确保该主机名已经在`/etc/hosts`中存在解析）

  多个主机之间可以使用逗号分隔

  可重复使用该参数指定多个主机

  主机名可以使用正则表达式

- `-l` 目标主机的用户名

  如果不指定用户名，默认以当前用户名作为在目标主机上执行命令的用户名。

  *例如：当前执行pdsh的用户为root，则以root用户在目标主机上执行命令*

- `-x` 排除 主机

```shell
pdsh -w 192.168.0.1 -w 172.16.0.1 -w master  #可以回车后再输入命令，也可以在最后紧跟一条命令
pdsh -w c[1-10] date  #对c1--c10主机执行date命令
pdsh -w c[1-10] -x c2 poweroff  #对c1--c10 排除c2 执行关机命令
pdsh -w c1,c10,master reboot  #对c1,c10,master执行重启命令
pdsh -w c[1-10] -l test  ls #使用test用户在c1--c10执行ls命令
```

主机列表文件：`/etc/pdsh/machines`，每行一个。