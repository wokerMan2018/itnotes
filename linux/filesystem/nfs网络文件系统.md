> NFS 网络文件系统(Network File System) 是由Sun公司1984年发布的分布式文件系统协议。



# 安装

- 服务端和客户端均安装`nfs-utils`，如还需支持v4版以前的协议，还需要安装`rpcbind`。

- 服务端启动`nfs`（或名`nfs-server`）服务，如还需支持v4版以前的协议，还需启用`rpcbind`服务。

- 按需对**防火墙配置**策略（或关闭防火墙）。
- **如果客户端和服务端有较大时间差距，NFS 可能产生非预期的延迟。**

# 服务端配置

## 配置文件

编辑`/etc/exports`，添加导出文件系统的相关配置：

```shell
#共享目录 允许访问的主机(配置选项)
/share 192.168.0.0/24(rw,async,insecure,no_root_squash)
/share 192.168.1.1(ro,async)
```

`/share`  为共享目录

`192.168.0.0/24`为可访问的网段（可以是域名，**支持通配符**）

括号中为各个选项，部分选项说明：

- 访问权限
  - `ro`只读 
  - `rw`可读写

- 安全策略

  - `insecure`  允许客户端使用1024以上的端口
  - `secure`  限制客户端只能使用小于1024的端口
  - `subtree_check`   NFS检查父目录的权限（默认） 
  - `no_subtree_check` 不检查父目录权限 （！关闭subtree简查可以提高性能，但是安全性降低。）
  - `exec`或`noexec`  可以或不可执行二进制文件

- 数据写入规则

  - `async`  文件暂存于内存（另`sync`文件存储在内存中并写入硬盘）
  - `wdelay` 如果多个用户要写入NFS共享目录，则归组写入（默认） 
  - `no_wdelay` 如果多个用户要写入NFS目录，则立即写入，**当使用async时，无需此设置**。 
  - `size`  缓冲区大小

- 用户映射

  - `root_squash`  NFS客户端连接服务端时如果使用的是root访问共享目录，将root用户映射成匿名用户（nobody）。
  - `all_squash` NFS客户端连接服务端上的任何用户访问该共享目录时都映射成匿名用户。
  - `no_root_squash`  NFS客户端连接服务端时如果使用的是root访共享目录，客户端对服务端分享的目录也拥有root权限。（！根据具体情况使用，务必**注意安全问题**）
  - `anonuid=` 将远程访问的所有用户都映射为匿名用户，并指定该用户为本地用户(id)；
  - `anongid=` 将远程访问的所有用户组都映射为匿名用户组账户，并指定该匿名用户组账户为本地用户组账户（gid）。

- `no_hide` 共享NFS目录的子目录（默认）

- `bg`/`fg` 以后台/前台形式执行挂载

- `fsid=数字`或`fsid=root`或`fsid=uuid`  导出的文件系统（即共享目录的文件系统）的识别号。

  通常fsid是文件系统的UUID（默认值）；不存储在该设备上的文件系统和没有UUID的文件系统需要显示地指定fsid（该值需唯一）。

  如果使用NFSv4，其能够指定所有导出的文件系统的root，通过`fsid=root`或`fsid=0`来标识。系统不能指定时须手动添加该配置项。

  注意：`fsid=0`选项的时候只能共享一个目录，这个目录将成为NFS服务器的根目录。

## 导出文件系统exportfs

管理当前NFS共享的文件系统。参数：

- `-a` 打开或取消配置文件中导出的共享目录
- `-r` 重新读取配置文件
- `-u` 取消导出的共享目录
- `-v`  输出详细信息

```shell
exportfs #查看已经配置的共享目录
exportfs -ra #重新载入配置 修改配置文件后可使用改命令
exportfs -au #取消所有导出
```

# 客户端挂载

## 挂载

*示例挂载192.168.0.251的/share到客户端的/share。*

- 使用mount 挂载

  - linux

    ```shell
    mount -t nfs 192.168.0.251:/share /share
    ```

  - windows

    ```powershell
    mount -o nolock \\192.168.0.251\! Z:
    ```

    挂载到Z盘。（可使用任务计划程序实现自动挂载）

- 使用fstab挂载

  写入`/etc/fstab`， 示例：

  ```shell
  192.168.0.251:/share /share nfs default,_netdev	0 0
  ```

- 其他图形界面工具

## 获取挂载信息showmount

参数：

- `-a` 列出所有客户端挂载点信息

- `-e` 显示服务端导出目录

- `-d` 列出客户端挂载的目录

  ```shell
  #showmont [参数] [地址/主机名]
  showmount  #显示挂载当前主机的客户端信息
  showmount -a
  showmount -d 192.168.0.251
  showmount -e 192.168.0.251
  ```

  以上命令如指定“地址/主机名”，默认使用当前系统主机名。

  如果使用`showmount -e`检测服务端服务器情况出现`clnt_create: RPC: Program not registered`错误，表示rpc程序未注册成功，关闭`rpcbind`和`nfs`，再依次重启即可。

  ```shell
  systemctl stop rpcbind
  systemctl stop nfs
  
  systemctl start rpcbind
  systemctl start nfs
  ```

## 其他相关命令

查看nfs状态（服务端）：`nfsstat`

查看rpc执行信息：`rpcinfo`