[TOC]

# 远程登录

```bash
ssh [-p port] user@host
ssh -p 2333 root@10.10.1.1
```
- port：要登录的远程主机的端口，如果省略，则默认为22（以下示例中如无指定均表示使用22）。

- user：要登录的主机上的用户名，如果省略用户名（和`@`），将会以当前用户名尝试登录ssh服务器，例如root用户执行`ssh host`同于`ssh root@host`。
- host：要登录的主机地址

## 密钥登录

使用非对称加密的密钥，可免密码登录。

1. 生成密钥——生成非对称加密的密钥对

   ```shell
   ssh-keygen   #根据提示选择或填写相关信息
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" #相等于执行ssh-keygen后一直回车(均默认)
   ```
   - t：加密类型，有dsa、ecdsa 、ed25519、rsa等
   - b：密钥长度
   - f：密钥放置位置
   - N：为密钥设置密码

2. 上传密钥——将密钥对中的公钥上传到ssh服务器

   ```shell
   ssh-copy-id user@host
   ssh-copy-id -i ~/.ssh/test.pub user@host  #有多个公钥时可使用参数-i指定一个公钥
   ```

   提示：上传时需要输入密码。

   公钥内容将添加到登录用户在服务器的`~/.ssh/authorized_keys`文件中。

## 别名登录

为需要经常登录的服务器设置别名，简化登录步骤。

在`~/.ssh/config`（如无该文件则创建之）中配置：

```shell
Host host1 #host1为所命名的别名
  hostname xxx.xxx.xxx.xxx #登录地址
  user user1  #用户名
  #port 1998  #如果修改过默认端口则指定之
  #IdentityFile  ~/path/to/id_rsa.pub #如果要指定公钥
  #IdentitiesOnly yes #只使用指定的公钥进行认证
```

登录时直接使用`ssh host1`即可。

## 跳板登录

在某些情况下，需要先登录跳板机（可能不止一个跳板机），再从跳板机登录到目标服务器：

**客户端** ---> **跳板机** ---> **目标主机**

- 分配伪终端跳转登录`-t`

  ```shell
  ssh -t user@jump ssh -t user@target
  ```

  多个跳板机时，按顺序一一写上即可。

  如果以上各步骤的ssh登录都实现了ssh密钥验证，将直接登录到目标主机。如果某一步登录无密钥验证，将会提示输入密码。

- 跳跃登录`-J`——更为简洁的用法：

  ```shell
  ssh -J user@jum[:port] user@target
  #如有多个跳板机使用逗号隔开
  ssh -J user@jump1,user@jump2 user@target
  ```

  注意：只有跳板机才能使用`:`进行端口指定，后面的目标服务器端口指定仍然只能使用`-p`指定。

- 代理命令`proxyCommand`

  ```shell
  ssh user@target -o ProxyCommand='ssh user@jump -W %h:%p'
  ```

  为了简化操作可使用[别名登录](#别名登录)：

  ```shell
  Host jump #跳板机配置
    HostName 10.10.1.1
    Port 2333
    User user1

  Host target #目标主机配置
    HostName 10.10.10.10
    Port 1010
    User user
    ForwardAgent yes
    ProxyCommand ssh jump -q -W %h:%p
  ```

  直接`ssh target`即可登录。

## 密钥转发

`-A`参数可将客户端密钥转发到目标服务器上。

也可以在ssh配置文件中添加`ForwardAgent yes`开启转发。

```shell
ssh -A -t user@jump ssh -A -t user@target
```

## 保持连接

默认情况下，连接的会话在空闲一段时间后会自动登出。为了保持会话，在长时间没有数据传输时客户端可以向服务器发送一个激活信号。与之对应，服务器也可以在一段时间没有收到消息时定期发送一个信号。

另外可开启`TCPKeepAlive`以发送TCP连接消息，其可检测到连接异常，以避免僵尸进程产生。

可根据情况在服务端或客户端设置：

- 服务端`/etc/ssh/sshd_config`中添加

  ```shell
  TCPKeepAlive yes  #可选 保持tcp连接
  ClientAliveInterval 60 #如果设置为0 则表示不发送激活信息。
  ClientAliveCountMax 5
  ```

  服务端每60s向连接的客户端传送信息，客户端连续5次无响应则自动关闭该连接。

- 客户端`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加

  ```shell
  TCPKeepAlive yes  #可选 保持tcp连接
  ServerAliveInterval 30
  ServerAliveCountMax 5
  ```

  每60s向连接的服务端端传送信息，服务端连续5次无响应则自动关闭该连接。

可以在ssh命令中使用`-o`参数指定向服务端发送激活信息间隔时间：

```shell
ssh -o ServerAliveInterval=60 user@host
```

## 连接复用

在已经连接到某个服务器的情况下，再连接该服务器时将直接从先前的连接缓存中读取信息，加快连接速度。

在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加：

```shell
ControlMaster auto
ControlPath ~/.ssh/socket/%r@%h:%p #连接信息存储路径
ControlPersist yes  #连接保持
ControlPersist 1h  #连接保持时间
```

## 远程操作

直接在登录命令后添加命令，可使该命令在远程主机上执行，示例：

```shell
ssh [-p port] user@host <command>
ssh root@192.168.1.1 whoami

#将本地.vimrc内容传入远程主机的.vimrc中
ssh root@192.168.1.1 'cat > .vimrc' < .vimrc

#多条命令使用引号包裹起来
ssh root@192.168.1.1 'echo `whoami` > name && mv -f name myname'
```

如果是交互式操作，例如使用vim操作远程主机的文件，配合scp使用，示例：

```shell
vim scp://user@host[:port]//path/to/file
```

## 登录失败原因

提示：可以在登录命令中加入`-v`参数，从输入内容中获取信息。

- 权限问题（客户端或服务端）

  **~/.ssh/authorized_keys文件的权限为600**，**~/.ssh文件夹权限为700**

  ```shell
  chmod 600 ~/.ssh* && chmod 700 ~/.ssh
  ```

- 客户端存在多个密钥对

  ssh默认使用的私钥可能和服务器上保存的客户端公钥并不是一对，可在登录时使用`-i`指定**私钥** ：

  ```shell
  ssh -i /path/to/private-key/ [-p port] user@host
  ```

- 严格的主机密钥检查不通过——服务器的公钥发生了变更

  ssh客户端首次登录ssh服务器时，客户端会记录服务器的公钥信息到`~/.ssh/known_hosts`（已知主机列表）文件中。
  而后每次客户端登录该服务器时，会先将`.ssh/know_hosts`中的公钥与服务器的公钥进行对比，二者一致才会通过校验。

  当ssh服务器公钥发生变化后，客户端的know_hosts中信息若未随之更新，就会校验不通过。

  解决方案：

  - 删除客户端`.ssh/known_hosts`文件中检查不通过的ssh服务器的公钥信息

  - 关闭客户端的严格主机密钥检查(strict host key check)

    在`.ssh/config`（或`/etc/ssh/ssh_config`）中添加

    ```shell
    StrictHostKeyChecking no
    ```

  如果无需严格的主机密钥检查，也可以将已知主机信息文件指向`/dev/null`。

# 端口转发（ssh隧道）

> 隧道是一种把一种网络协议封装进另外一种网络协议进行传输的技术。

以下关于不同转发的论述中的三种角色：

客户端：原始请求的发起者

目标主机：真正的服务提供者

代理：客户端与服务端（目标）的中介

---

- 使用1024以下的端口需要root权限。

- 端口转发命令配合`-g`参数，可允其他主机连接到转发的端口，如果不使用该参数则只允许本地主机建立连接。也可在代理主机的配置文件`/etc/ssh/sshd_config`中设置：`GatewayPorts yes`，以允许远程主机建立连接。

- 禁止端口转发：在配置文件`/etc/ssh/sshd_config`中设置`AllowTcpForwarding no`。

- 动态转发与本地/远程转发

  **动态转发是正向代理，本地/远程转发是反向代理。**

  **”正向“代理客户端，”反向“代理服务端。**

  （这里的”正向“是正向代理的简称，代理作动词，”反向“亦同）

  正向代理代表客户端向服务器发送请求，使真实客户端对服务器不可见。反向代理代表服务器为客户端提供服务，使真实服务器对客户端不可见。

- 本地转发和远程转发

  在本地转发和远程转发的应用中，客户端都是直接访问代理主机的端口，代理主机通过端口转发，将数据传送到真实目标主机相应的端口上。

  本地主机是指执行转发命令这台主机，“远程”主机指的是另一台主机（并不时距离远近的意思）——但也二者也可以是同一设备，自己向自己转发（转发到同一地址的不同端口或不同网口地址的端口）。

  二者不同在于：

  - 执行转发命令的主机
    - 本地转发中，执行转发命令的是**代理主机**（即所谓“本地”主机）。
    - 远程转发中，执行转发命令的是**目标主机**（代理主机即所谓“远程”主机）

    此外，动态端口转发中，执行转发命令的是**客户端**。

  - 客户端的访问方向

    - 本地转发：**客户端** ---> **执行转发操作的主机（代理）**---> **目标**
    - 远程转发：**客户端** ---> **远程主机（代理）** ---> **执行转发操作的主机（目标）**

---

*以下示例中，代理主机地址为10.10.1.1，端口2333，用户名user1。目标主机地址为10.10.10.10，端口1010，用户名user。*

## 动态端口转发（socks代理）

在客户端执行转发命令

转发客户端的端口到代理主机的端口，客户端经过代理主机访问远端资源。可用于代理/加密访问。

```shell
ssh -D  [bind_address:]<local-port> <proxy-user>@<proxy-host> [-p proxy-port]
```

- bind_address：指定绑定的IP地址，如果空值或者为`*`会绑定本地所有的IP地址；如果希望绑定的端口仅供本机使用，可以指定为`localhost`。
- local-port：本地绑定的端口

客户端配置socks5代理后使用（或设置全局的代理，可配合PAC使用）。

应用示例：

主机A因为某防火墙缘故不能访问某网站`elgoog.com`，但主机A可访问美利坚服务器主机P，而P可以访问`elgoog.com`。可在主机A使用动态端口转发（fCNT等参数参看[常用参数](#常用参数)）：

```shell
ssh -gfCNTD *:2333 user@hostP
```

*参看[参数说明](#常用参数)：g允许访问网关端口 ，f放入后台执行， C压缩数据 ，N不在远程主机执行命令，T不分配tty。*

而后在主机A上配置socks5代理：地址为`localhost`或`127.0.0.1`或A的ip地址，端口为2333，主机A即可通过服务器P代理访问`elgoog.com`。

另，由于转发时使用的`*`指定绑定地址，因此其他能够访问A的主机也能设置socks5代理：地址为A的ip地址，端口为2333，通过服务器P代理访问`elgoog.com`。

## 本地端口转发

**在代理主机执行转发命令**

转发本地主机端口的数据到远程主机端口，访问本地主机的端口即相当于访问远程主机的端口。

这里的远程主机是最终提供服务的目标主机，本地主机为其充当代理。

```shell
ssh -L [bind_address:]<proxy-port>:<target-host>:<target-port> [user>@]<ssh-server>
```

其余参数解释参看动态转口转发。

ssh-server：可以是

如果转发了目标服务器的ssh端口，客户端需要ssh登录到目标主机，需**使用目标主机上的用户名**访问代理主机的端口来登录：

```shell
ssh -p <proxy-port> [<target-user>@]<proxy-host>
ssh -p 2222 user1@10.10.1.1 #user1是目标服务器上的root账户
```

## 远程端口转发

**在目标主机执行转发命令**

转发远程主机端口的数据到本地主机端口，访问远程主机的端口即相当于访问本地主机的端口。

这里的本地主机是最终提供服务的目标主机，远程主机为其充当代理。

```shell
ssh -R [bind_address:port:<local-host>:<local-port> [<remote-user>@]<remote-host>
```

- ssh-server：可以目标主机（target-host），但也可以另一台主机。

参数解释参看动态转口转发。

如果转发了目标服务器的ssh端口，客户端需要ssh登录到目标主机，同上文本地端口转发中登录ssh的方式。

一个远程转发示例，内网主机ssh远程转发本地22端口到公网服务器2333端口：

```shell
#remote-user为公网服务器上的用户 remote-host为公网服务器的地址
sh -gfCNR 2333:localhost:22 <remote-user>@<remote-host> -o TCPKeepAlive=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=10
```

其他设备通过公网服务器的2333端口ssh登录内网设备：

```shell
#这里的user是内网主机上的用户 而remote-host是公网服务器的地址
ssh -p 2333 <user>@<remote-host>
```

# 文件传输

## scp远程复制

scp是基于ssh的远程复制，使用**类似cp命令**。基本形式：

```shell
scp </path/to/local-file> user@host:</path/to/file>  #本地到远程
scp user@host:</path/to/file> </path/to/local-file>  #远程到本地
```

注意：scp遇到软连接时，**会复制软连接的源文件**！可以打包要复制的文件，待scp复制到目标主机后再解包，或者换用其他工具如rsync。

常用选项：

- -P  指定远程主机的端口号
- -C  使用压缩
- -r  递归方式复制（即复制文件夹下所有内容）
- -p  保留文件的权限、修改时间、最后访问时间
- -q  静默模式（不显示复制进度）
- -F  指定配置文件

示例——复制本地ssh公钥到远程主机：

```shell
#复制本地公钥到远程主机 并将其命名为authorized_keys
scp ~/.ssh/id_rsa.pub root@ip:/root/.ssh/authorized_keys
#指定端口需要紧跟在scp之后
scp -P 999 ~/.ssh/id_rsa.pub root@ip:/root.ssh/authorized_keys
```

## sftp传输协议

使用sftp协议可以同ssh服务器进行文件传输，访问地址类似：

> sftp://192.168.1.100:22/home/<user>/path/to/file

## sshfs文件系统

> SSHFS 是一个通过 SSH 挂载基于 FUSE 的文件系统的客户端程序。

需要安装有`sshfs`。

挂载示例：

```shell
#sshfs [user@]host:[dir] <mountpoint> [options]
sshfs ueser1@host1:/share /share -C -p 2333 -o allow_other
```

常用选项有：

- `-C` 启用压缩

- `-p` 指定端口

- `-o allow_other` 允许非root用户读写


`/etc/fastab`自动挂载示例：

```shell
user@host:/remote/folder /mount/point  fuse.sshfs noauto,x-systemd.automount,_netdev,users,idmap=user,IdentityFile=/home/user/.ssh/id_rsa,allow_other,reconnect 0 0
```



卸载示例：

```shell
#fusermount -u <mount-point>
fusermount -u /share
```

# 服务器安全策略

## 工具

- [fail2ban](https://github.com/fail2ban/fail2ban)
- [sshguard](https://www.sshguard.net/)
- [denyhosts](https://github.com/denyhosts/denyhosts)

## 白名单和黑名单

- 黑名单

  在`/etc/hosts.deny`中添加禁止列表。

- 白名单

  在`/etc/hosts.allow`中添加允许列表。


- 更改默认的22端口
  修改服务器的`/etc/ssh/sshd_config`文件中的`Port` 值为其他可用端口。

- 登录记录查看

  - 成功记录：`lastlog`

    其保存在`/var/log/secure`（或在`/etc/log/btmp`）。

  - 失败记录：`lastb`

    其保存在`/etc/log/btmp`。


- 使用非对称加密密钥

  ```shell
  ssh-keygen  #或者ssh-keygen -t rsa 4096 客户机生成密钥
  ssh-copy-d -p 23579 ip@8.8.8.8  #上传公钥到服务
  ```

  注意，dsa密钥已经证实为不安全，rsa密钥位数过低也较为不安全，推荐至少4096位。


- 用户控制

  - 禁用root登录
    修改服务器的`/etc/ssh/sshd_config`文件中的`PermitRootLogin` 值改为no
  - 禁止root用户使用密码登陆（可使用密钥登陆）
    仅禁止使用密码登陆root账户， 将服务器的`/etc/ssh/sshd_config`文件中的`PermitRootLogin` 值改为`prohibit-password`

  - 禁止登录shell

    - 在`/etc/passwd`文件中找到该用户所在行，将`/bin/bash`字样改为`/sbin/nologin`。

    - 在ssh配置文件中添加`DenyUsers username`（username即用户名，下同）。

    - 在`/etc/pam.d/sshd`文件中添加：

      > auth  required  pam_listfile.so  item=user  sense=allow  file=/etc/ssh/deny onerr=succeed

      在`/etc/ssh/deny`中加上要禁止的用户名

  - 只允许某些用户登录

    在ssh配置文件中内容：

    - 允许单用户：`AllowUsers username`
    - 允许用户组：`AllowGroups groupname`（groupname是组名）

----

# 常用参数

- `p`：指定要连接的远程主机的端口
- `f`：成功连接ssh后将指令放入后台执行
- `C`：请求压缩所有数据
- `N`：不执行远程命令（不登录到服务器执行命令）
- `D`：动态端口转发
- `R`：远程端口转发
- `L`：本地端口转发
- `g`：（配合端口转发）允许远程主机连接到建立的转发的端口（不使用该参数则只允许本地主机建立连接）
- `-t`：强制分配伪终端（可以用来执行任意的远程计算机上基于屏幕的程序）
- `T`：不分配TTY
- `A`：开启身份认证代理转发
- `q`：安静模式（不输出错误/警告）
- `-v`：显示详细信息（可用于排错）

# 问题解决

- > Permission denied (publickey,gssapi-keyex,gssapi-with-mic)

  检查`/etc/ssh/sshd_config`是否关闭了密码登录。如需开启密码登录，修改该行：

  ```
   PasswordAuthentication no #注释该行或值改为yes 再重启sshd服务
  ```

- > no matching key exchange method found. Their offer: diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1

  ssh server 不支持diffie-hellman-group1-sha1造成的，服务器ssh版本过低（或者说客户端ssh版本过高）。

  升级服务端ssh版本，或在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加

  ```shell
  KexAlgorithms +diffie-hellman-group1-sha1
  ```

- > no compatible cipher.The server supports these cipher:  aes128-ctr,aes192-ctr,aes256-ctr

  ssh服务端不支持某些协议（或者说客户端ssh版本过高）。

  升级服务端ssh版本，或在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加

  ```shell
  Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc
  ```
