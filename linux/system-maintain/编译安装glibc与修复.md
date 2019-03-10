查看glibc版本

```shell
strings /lib64/libc.so.6 | grep GLIBC
```

# 修复glibc

手动编译升级glibc一定要慎重。

> glibc是GNU发布的libc[库](http://baike.baidu.com/view/226876.htm)，即c运行库。glibc是linux系统中最底层的api，几乎其它任何运行库都会依赖于glibc。glibc除了封装linux操作系统所提供的系统服务外，它本身也提供了许多其它一些必要功能服务的实现。由于
> glibc 囊括了几乎所有的 UNIX 通行的标准，可以想见其内容包罗万象。

特别是 libc.so.6这个文件一旦误删除或变更，系统大部分命令都将失效，整个系统基本报废。

*如果误操作的主机是远程主机，千万不要退出SSH，否则再也登录不上去，因此建议先以tmux和screen之类的工具开启一个后台窗口，然后远程登录到目标主机。*

或曰：

> 升级千万条
>
> 慎重第一条
>
> 编译不规范
>
> 跑路两行泪

执行以下命令立即修复为旧版本的glibc：

```shell
LD_PRELOAD=/lib64/libc-2.15.so ln -sf /lib64/libc-2.15.so libc.so.6
# unset LD_PRELOAD  #去掉LD_PRELOAD
```

这里的2.15应该以原来系统存在的glibc版本更改。

# 编译安装glibc

1. 下载glibc-2.14.tar.gz glibc-ports-2.14.tar.gz

2. 编译安装

   ```shell
   prefix=/usr/local/glibc-2.14
   
   tar -xvf glibc-2.14.tar.gz 
   tar -xvf glibc-ports-2.14.tar.gz
   mv glibc-ports-2.14 glibc-2.14/ports -f
   cd glibc-2.14
   mkdir build -p
   cd build
   ../configure --prefix=$prefix
   make -j4
   make localedata/install-locales   #不执行该命令会导致local问题
   cp /etc/ld.so.conf $prefix/etc/
   make install
   
   #if检查以下动态文件存在与否 
   if [[ -f  ]]
   then
     export LD_LIBRARY_PATH=$prefix/lib:$LD_LIBRARY_PATH
   fi
   #待确实没有问题存在再将path写到文件中
   echo "export LD_LIBRARY_PATH=$prefix/lib:\$LD_LIBRARY_PATH" > /etc/profile.d/glibc.sh
   ```

   千万不要轻易执行ln -sf来覆盖原libc.so.6动态库，即使要覆盖，也先检查新版本libc动态库存在与否，避免将不存在的文件软链接到libc.so.6造成损害整个系统。

   如果误操作请不要退出终端，立即参看[修复glibc](#修复glibc)。