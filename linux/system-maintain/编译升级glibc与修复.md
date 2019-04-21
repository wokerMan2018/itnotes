查看当前glibc版本

```shell
strings /lib64/libc.so.6 | grep GLIBC
```

# 修复glibc

手动编译升级glibc一定要慎重。如无绝对必要，不要升级。

> glibc是GNU发布的libc[库](http://baike.baidu.com/view/226876.htm)，即c运行库。glibc是linux系统中最底层的api，几乎其它任何运行库都会依赖于glibc。glibc除了封装linux操作系统所提供的系统服务外，它本身也提供了许多其它一些必要功能服务的实现。由于
> glibc 囊括了几乎所有的 UNIX 通行的标准，可以想见其内容包罗万象。

特别是 libc.so.6这个文件一旦误删除或变更，系统大部分命令都将失效，整个系统基本报废。

*如果误操作的主机是远程主机，千万不要退出SSH，否则再也登录不上去，因此建议在进行此类重要软件包升级前，先以tmux和screen之类的工具开启一个后台窗口备用。*

执行以下命令立即修复为旧版本的glibc：

```shell
LD_PRELOAD=/lib64/libc-2.12.so ln -sf /lib64/libc-2.12.so libc.so.6
unset LD_PRELOAD  #去掉LD_PRELOAD
```

这里的2.12应该以原来系统存在的glibc版本更改。

# 编译安装glibc

例1--2.12升级2.14

1. 确保安装了gcc gcc-c++ make

2. [下载2.14版本glibc和glibc-ports](https://ftp.gnu.org/gnu/libc/)（2.16及以下版本才需要glibc-ports）

3. 编译安装

   ```shell
   ver=2.14  #glibc版本
   dist=/usr/local/glibc-$ver  #glibc安装的路径
   
   tar -xJvf glibc-$ver.tar.xz 
   tar -xvf glibc-ports-$ver.tar.xz  #2.16及以下版本需要
   mv glibc-ports-$ver glibc-$ver/ports -f  ##2.16及以下版本需要
   cd glibc-$ver
   mkdir build -p
   cd build
   ../configure --prefix=$dist
   make -j4 && make install
   make localedata/install-locales   #2.16及以下版本需要执行避免locale问题
   cp /etc/ld.so.conf $prefix/etc/  #2.16及以下版本需要执行
   make install
   
   #if检查以下动态文件存在与否 
   if [[ -f $prefix/lib/libc-$ver.so ]]
   then
     export LD_LIBRARY_PATH=$dist/lib:$LD_LIBRARY_PATH
   fi
   #先检查原先的libc版本
   ls -l  /lib64/libc.so.6
   oldlibc=$( ls -l  /lib64/libc.so.6|cut -d ">" -f 2)
   echo $oldlibc
   #尝试一些命令 如cp w 等 确实没有问题存在再替换软连接
   ln -sf /usr/local/glibc-$ver/lib/libc-$ver.so /lib64/libc.so.6
   strings /lib64/libc.so.6|grep GLIBC
   
   #如果执行date提示Local time zone must be set--see zic 执行：
   ln -sf /etc/localtime /usr/local/glibc-$ver/etc/localtime
   #echo "export LD_LIBRARY_PATH=$prefix/lib:\$LD_LIBRARY_PATH" > /etc/profile.d/glibc.sh
   ```

   

如果误操作请不要退出终端，立即参看[修复glibc](#修复glibc)。