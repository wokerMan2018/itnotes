# 准备工作

如果非单一节点的情况：

- 选定一个节点作为openlava服务器（管理节点），配置该节点到其他节点的ssh密钥登录。
- 确保所有节点使用同一用户运行openlava（可使用nis等服务）。
- 在管理节点的hosts文件（`/etc/hosts`）中加入其他节点的hostname解析：

# 编译安装

编译及运行所需依赖

- gcc
- ncurses-devel
- tcl-devel

修改集群说明信息(lsid)，编辑`lsf/lsftools/lsid.c`中相关说明文字。(todo)

```shell
clusterName='xxxhpc'
userName='manage\ node\ is'
sed -i s/'My cluster name is %s'/$clusterName\\n/ lsf/lsftools/lsid.c
sed -i s/'My master name is'/$clusterName/ lsf/lsftools/lsid.c
```

以编译安装安装到`/opt/openlava`为例，下同。

```shell
dest=/share/openlava
./configure --prefix=$dest
make
make install

#生成配置文件
./config.status
\cp config/* $dest/etc -f
cd $dest/etc
\rm Makefile* *.in -f
```

# 应用配置

- 执行用户和环境变量

  ```shell
  dest=/share/openlava
  user=hpcadmin
  #创建运行openlava的用户 r创建为系统用户 M不创建家目录 s指定shell
  useradd -rM /sbin/nologin $user
  chown -R $user $dest
  sed -i s/openlava/$user/ $dest/etc/lsf.cluster.openlava
  
  #环境变量
  cd $dest/etc/
  chmod +x $dest/etc/openlava*
  source ./openlava.sh
  ./openlava.setup
  ln -sf $dest/etc/openlava $dest/bin/
  
  #设置开机自启动
  systemctl enable openlava
  ```

- 主配置文件

  修改文件`lsf.cluster.openlava`（openlava字样可改为集群名字），部分内容如下：

  ```shell
  Begin   ClusterAdmins
  Administrators = openlava #运行openlava服务的用户
  End    ClusterAdmins
  
  Begin   Host  #主机列表
  HOSTNAME    model    type  server  r1m  RESOURCES
  #yourhost IntelI5    linux   1      3.5    (cs)
  #node1       !       linux   1      3.5    (cs)
  master       !      linux    1      3.5    (cs) 
  c01          !      linux    1      3.5    (cs)
  End     Host
  ```

  主机列表中，第一行被认为是管理节点，其后一一添加其他节点。

# 启动服务

```shell
#所有节点启动openlava
openlava start
#查看运行状态
openlava status
#检查配置文件
badmin ckconfig
lsadmin ckconfig
```

- 重新应用配置

  在未停止openlava服务而修改过配置文件后使用

  ```shell
  badmin reconfig
  lsadmin reconfig
  ```

- 运行中添加新节点

  1. 参照上文在新节点部署好openlava并启动

  2. 在管理节点使用lsaddhost添加新节点并重启应用配置

     ```shell
     lsaddhost <hostname>
     badmin reconfig
     lsadmin reconfig
     ```