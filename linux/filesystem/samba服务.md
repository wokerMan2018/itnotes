Samba一种支持[SMB/CIFS](https://zh.wikipedia.org/wiki/%E4%BC%BA%E6%9C%8D%E5%99%A8%E8%A8%8A%E6%81%AF%E5%8D%80%E5%A1%8A)（Server Message Block/Common Internet File System）协议的文件共享工具。

# 服务端

安装`samba`，启用`smb`和`nmb`服务（或名`smbd`或`nmbd`）。

*因安全性问题，不推荐在互联网上使用samba。*

samba使用445 TCP/UDP端口：

- nmb
  - TCP 445 ：Microsoft-DS Active Directory、Windows 共享资源（TCP）
  - UDP 445 ：Microsoft-DS SMB 文件共享（UDP）
- smb
  - UDP 137： NetBIOS 命名服务（WINS）
  - UDP 138 ：NetBIOS 数据包

*旧版本samba共享协议使用的139端口（作用同445端口）存在较大安全隐患，不推荐使用。*

## 配置

主配置文件`/etc/samba/smb.conf`：

```shell
#===globale config===
[global]
   # multi config(smb.conf.host1 smb.conf.host2)
   ;config file = /etc/samba/smb.conf.%m
   
   workgroup = MYGROUP
   netbios name = SAMBA-SERVER @ %h
   server string = Samba Server %v
   ;wins server = 192.168.1.251
   # default is 445
   ;smb ports = 4455
   
   # default guest name is "nobody"
   ;guest account = guest
   # log file
   ;log file = /usr/local/samba/var/log.%m
   # log file maxium size
   max log size = 50

   # for multiple interfaces(user name or addr)
   ;interfaces = eth0
   ;interfaces = 192.168.12.2/24 192.168.13.2/24 

	# allow / deny clients
   ;hosts allow = 192.168.1. 127. 172.17.2.EXCEPT172.17.2.50 192.168.10.*
   ;hosts deny = c01,c02 @students 192.168.1.10 172.17.2.0/16

	# max connections, default is 0 (no limited)
   ;max connections = 0
	
	printing = cups
    printcap name = cups
    load printers = yes
    cups options = raw

#===printers===
[printers]
   comment = All Printers
   path = /var/tmp/samba/printer
   browseable = no
   public = yes
   writable = no
   create mask = 0600
   printable = yes

#===system user home dir===
[homes]
   comment = User Home
   browseable = no
   writable = yes
   inherit acls = yes

#common share dir
[public]
   comment = Public for everyone
   path = /home/public
   public = yes
   writable = no
   printable = no
   ;admin users = @wheel,levin
   ;valid users =
   ;invalid users =
   ;write list = @wheel,levin
   ;create mask = 0664
   ;directory mask = 0775
```
注意：配置文件中，可使用`#`、`!`或`;`**注释整行**，除中括号`[]`配置行所在行外，不可在该行配置内容后使用`#`、`!`或`;`加注释内容，否则启动服务会报错。

samba配置中各项名字意义较为明了，也可参看[配置文件](https://git.samba.org/samba.git/?p=samba.git;a=blob_plain;f=examples/smb.conf.default;hb=HEAD)。

使用`testparam`命令检测配置文件语法是否正确。

配置中常用变量：

- %S：取代目前的设定项目值（即`[ ]`中的内容）
- %m：客户机的 NetBIOS 主机名
- %M：客户机的 Internet  主机名（hostname）
- %L：服务器 NetBIOS 主机名
- %H：用户的家目录
- %U：目前登入的使用者的名称
- %g：目前登入的使用者的组名
- %h：目前服务器的hostname
- %I：客户机的 IP
- %T：目前的日期与时间
- %v：samba版本号

## 用户管理

samba需要linux系统账户才能使用，虽然其使用linux用户名，但是仍需设置独立的密码（可以同系统用户名密码相同），设置密码示例：

```shell
smbpasswd -a <username>  #添加samba用户并设置密码
smbpasswd <username>  #修改samba用户密码
```

提示：为了安全可以将仅用于samba服务的用户禁用shell登录

```shell
usermod -s /sbin/nologin
```

# 客户端

## linux

安装`cifs-utils`或`samba-client`（或名`smbclient` ）

如果samba主机是windows，在`/etc/nsswitch.conf`的host行添加wins，示例：

```shell
hosts: files dns myhostname wins
```

- 挂载

  - 可在支持samba的文件管理器中访问：`smb://samba服务器地址`，访问某个具体共享目录则是`smb://samba服务器地址/目录`。

    注意：如果访问用户家目录，地址后的目录名直接写用户家目录名即可，无需写出全部路径。

  - 命令手动挂载

    ```shell
    mount -t cifs //<SERVER/sharename> <mountpoint> -o user=<username>,password=<password>
    ```

    其他可用选项（均以逗号`,`分隔）：

    - `uid=<username>`
    - `gid=<group>`
    - `workgroup=<workgroup>`
    - `ip=<serverip>`
    - `iocharset=<utf8>`

  - 自动挂载（在`/etc/fstab`添加）示例：

    ```shell
    //smb-server/share /share cifs username=testuser,password=testpwd 0 0
    ```

- smbclient命令

  ```shell
  #显示可用共享
  smbclient -L <host> -U%
  #显示某个用户的可用共享
  smbclient -L <host> -U <username>
  ```

- smbtree命令：显示共享目录树（不建议再有大量计算机的网络上使用此功能）

  ```shell
  smbtree -b -N
  ```

  - -b (--broadcast) 使用广播模式
  - -N (-no-pass) 不询问密码


## windows

连接到`\\samba服务器地址\路径`