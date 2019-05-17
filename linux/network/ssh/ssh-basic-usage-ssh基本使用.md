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
   
   确保`authorized_keys`文件的权限为600，`.ssh`文件夹权限为700。

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

- 登录到跳板主机，再从跳板主机登录到目标就主机——转发密钥`-A`

  如果客户端上有和目标主机匹配的密钥，但跳板主机上没有和目标主机匹配的密钥（一般多是为了安全没有在跳板机和目标主机进行密钥认证），可使用密钥转发功能将客户端密钥转发到跳板机上。

  跳板上的`/etc/ssh/ssh_config`或(`~/.ssh/config`)需要配置开启`ForwardAgent yes`。

  1. 从客户端登录到跳板机，同时转发密钥到跳板机

     ```shell
     ssh -A user@jump-host
     ```

  2. 从跳板机登录到目标主机——跳板机登录目标主机时即可以使用客户端登录时转发而来的密钥

     ```shell
     ssh user@target-host
     ```

     

以下登录方式是直接在客户端上执行命令连接到目标主机，无需登录到跳板后再ssh登录到目标主机。

- 分配伪终端跳转登录到目标主机`-t`

  ```shell
  ssh -t user@jump-host ssh -t user@target-host
  ```

  多个跳板机时，按顺序逐个`ssh -t`即可。

  如果以上**各步骤的ssh登录都实现了ssh密钥验证，将直接登录到目标主机**。如果某一步登录无法密钥验证，将会提示输入密码。

- 跳跃登录到目标主机`-J`

  原理是在跳板机上建立TCP转发，让客户端ssh数据直接转发到目标服务器上等ssh端口。

  ```shell
  ssh -J user@jum[:port] user@target -p <port>
  #如有多个跳板机使用逗号隔开
  ssh -J user@jump1,user@jump2:2333 user@target -p 22
  ```

  如果**客户端和跳板机**以及**客户端和目标主机**均有匹配的密钥，则可以无需输入密码直接登录到目标主机。

  如果客户端和目标主机无密钥认证，即使跳板和目标主机有密钥认证，也无法直接免密码登录到目标主机。

  注意：只有跳板机才能使用`:`进行端口指定，后面的目标服务器端口指定仍然只能使用`-p`指定。

- 代理命令`proxyCommand`跳转登录到目标主机

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

## 连接复用

在已经连接到某个服务器的情况下，再连接该服务器时将直接从先前的连接缓存中读取信息，加快连接速度。

在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加：

```shell
ControlMaster auto
ControlPath ~/.ssh/socket/%r@%h:%p #连接信息存储路径
ControlPersist yes  #连接保持
ControlPersist 1h  #连接保持时间
```

## 远程命令

直接在登录命令后添加命令，可使该命令在远程主机上执行，示例：

```shell
ssh [-p port] user@host <command>
ssh root@192.168.1.1 whoami

#将本地.vimrc内容传入远程主机的.vimrc中
ssh root@192.168.1.1 'cat > .vimrc' < .vimrc

#多条命令使用引号包裹起来
ssh root@192.168.1.1 'echo `whoami` > name && mv -f name myname'
```

如果执行某个命令遇到`command not found`，而实际上远程主机上可以正常执行该命令，参看[问题解决](#问题解决)中“远程命令cmmand not found"。

远程命令执行完毕后，即会退出ssh连接。

使用`-t`参数分配伪终端，且远程命令的最后一条命令为`bash`（或其他shell），则可以在远程主机执行命令后仍停留在远程主机的shell中。

示例登录后自动进入某个目录：

```shell
ssh -t <host> 'cd /tmp;bash'
```

如果是交互式操作，例如使用vim操作远程主机的文件，配合scp使用，示例：

```shell
vim scp://user@host[:port]//path/to/file
```

# 端口转发

> 隧道是一种把一种网络协议封装进另外一种网络协议进行传输的技术。

- 使用1024以下的端口需要root权限。

- 端口转发命令配合`-g`参数，允许远程主机(remote hosts)连接到本地转发的端口(local forward port)，如果不使用该参数则只允许本地主机建立连接。

  也可在代理主机的配置文件`/etc/ssh/sshd_config`中设置：`GatewayPorts yes`，以允许远程主机向本地转发端口建立连接。

- 禁止端口转发：在配置文件`/etc/ssh/sshd_config`中设置`AllowTcpForwarding no`。

- 可配合[保持连接](#保持连接)的autossh，创建systemd units持续提供转发服务。

- 动态转发与本地/远程转发

  **动态转发是正向代理，本地/远程转发是反向代理。**

  **”正向(代理)“ 代理客户端**：正向代理代表客户端向服务器发送请求，使真实客户端对服务器不可见。

  **”反向(代理)“ 代理服务端**：反向代理代表服务器为客户端提供服务，使真实服务器对客户端不可见。

  (第2个代理是动词)

## 动态端口转发（socks代理）

在客户端执行转发命令，转发客户端的端口到代理主机的端口，客户端经过代理主机访问远端资源。

```shell
ssh -D  [bind_address:]<local-port> <proxy-user>@<proxy-host> [-p proxy-port]
```

- bind_address：指定绑定的IP地址，如果空值或者为`*`会绑定本地所有的IP地址；如果希望绑定的端口仅供本机使用，可以指定为`localhost`。

- local-port：本地绑定的端口

  

应用场景：代理访问（例如科学上网）、加密访问。

未使用转发时的网络连通情况：

```
客户端C ----------> 主机 P ---------> 许多目标主机Ts

客户端C ------> X本来应该可以连通但是...不可达 X----->许多目标主机Ts
```

使用转发后客户端C发起请求与目标T返回应答的示意：

```
客户端C ====>请求>=====>代理主机P~~~~~~~~~~>目标主机T

客户端C <=========代理主机P<~~~~~<应答<~~~~~目标主机T
```

1. 在客户端（计算机C）上执行动态转发：

   ```shell
   ssh -fCNTD *:2333 user@hostP
   ```

   参看[参数说明](#常用参数)了解各个参数意思。

2. 在客户端上配置socks5代理

   - 地址为`localhost`或`127.0.0.1`或C与P进行网络连接的网口的ip地址
   - 端口为2333

   客户端C即可通过服务器P代理访问`elgoog.com`。

   提示：客户端配置socks5代理后使用（或设置全局的代理，可配合PAC使用）。

## 本地端口转发

**将本地主机的指定端口的流量，转发到目标远程主机的指定端口**。因此就可以通过访问本地端口实现访问目标端口的服务。

本地转发中：

- 本地主机L：作为执行转发命令主机L；作为流量转发的中间代理主机P。
- 远程主机R：最终提供服务的目标主机T。

未使用转发时的网络连通情况：

```
客户端C ----------> 本地主机L ---------> 目标主机T/远程主机R
```

使用转发后客户端C发起请求与目标T返回应答的示意：

```
客户端C ====>请求>=====>本地主机L作代理~~~~~~~~~>目标主机T

客户端C <=========本地主机L作代理<~~~~~<应答<~~~~~目标主机T
```



应用场景举例：网络安全管控。内网中只有主机A可以访问外网，转发主机A端口到外网服务器B的web端口，其他内网主机无需连接外网，也能通过访问主机A的端口访问B的web服务 。



```shell
ssh -L [bind_address:]<local-port>:<target-host>:<target-port> [user>@]<local-host>
#转发该主机的8080端口到kernel.org的80端口   访问该主机的8080端口的流量即被转向www.kernel.org
ssh -fNCL 8080:www.kernel.org:80 user@localhost
```

客户端登录远程目标主机时，用户名为**远程目标主机上的用户名**，端口为执行转发的本地主机的端口，主机为执行转发的本地主机。

```shell
ssh -p <-local-port> [<remote-host-user>@]<local-host>
ssh -p 2222 user1@10.10.1.1 #user1是目标服务器上的root账户
```

## 远程端口转发（反向隧道连接）

将远程主机的指定端口的流量转发到本地主机的指定端口。远程转发场景中，本地主机作为提供服务的目标，其主动向远程主机建立一个反向隧道，通过访问远程主机的端口，即可通过反向隧道目标端口的服务。

本地转发中：

- 本地主机L：执行转发命令主机L；最终的访问目标主机T。
- 远程主机R：作为流量转发的中间代理主机P。

未使用转发时的网络连通情况：

```markdown
客户端C ----------> 远程主机R <--------- 目标主机T/本地主机L
```

本地主机主动向远程主机发起链接，建立反向隧道：

```
本地主机L/ 目标主机T <############ 远程主机R/代理主机P
```

使用转发后客户端C发起请求与目标T返回应答的示意：

```shell
客户端C ====>请求>====>远程主机R作代理~~~~~~~~>目标主机T/本地主机L

客户端C <=====远程主机R作代理<~~~~~<应答<~~~~~目标主机T/本地主机L
```



应用场景举例：内网穿透。将内网的服务器端口通过转发映射到公网主机端口，其他主机通过公网主机访问位于内网的服务。



```shell
ssh -R [bind_address:port:<local-host>:<local-port> [<remote-user>@]<remote-host>
#在本地主机执行     转发远程主机的10022端口到本地主机的22端口
#访问远程主机的10022端口  即可通过反向隧道访问到本地主机的22端口
ssh -fNCL 10022:localhost:22 user@remte-hos
```

客户端登录目标主机时，用户名为**目标主机上的用户名**，主机名和端口为远程主机（代理主机）的端口，主机为远程主机。

```shell
ssh -p 10022 <user>@<remote-host>
```

# 保持连接

## alive存活保持

默认情况下，连接的会话在空闲一段时间后会自动登出。为了保持会话，在长时间没有数据传输时客户端可以向服务器发送一个激活信号；与之对应，服务器也可以在一段时间没有收到客户端消息时定期向客户端发送一个激活信号。

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
  ServerAliveInterval 60
  ServerAliveCountMax 5
  ```

  每60s向连接的服务端端传送信息，服务端连续5次无响应则自动关闭该连接。

也可以在ssh命令中使用`-o`参数指定向服务端发送激活信息间隔时间：

```shell
ssh -o ServerAliveInterval=60 user@host
```

## autossh工具

autossh可以在监测ssh连接状态，当ssh断开后会自动重新发起连接。

在ssh命令前使用`autossh -M <port>`即可，其指定一个端口，用以持续监听当前ssh连接状态。

```shell
autossh -M 2333 ssh -fCNR 8080:localhost:80 user@remote-host
```



一个autossh的systemd units文件示例，可放置于`/etc/systemd/system/autossh.service`或`$HOME/.config/systemd/user/`下。

```shell
[Unit]
Description=Keeps a tunnel to 'example.com' open
After=network.target

[Service]
User=autossh
ExecStart=/usr/bin/autossh -M 5678 -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3" -NR 1234:localhost:22 -i /home/autossh/.ssh/id_rsa someone@remote-host
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

## 

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

# 安全策略

- 登录记录查看

  - 成功记录：`lastlog`

    其保存在`/var/log/secure`（或在`/etc/log/btmp`）。

  - 失败记录：`lastb`

    其保存在`/etc/log/btmp`。

- 防御工具

  - [fail2ban](https://github.com/fail2ban/fail2ban)
  - [sshguard](https://www.sshguard.net/)

- 白名单和黑名单
  - 黑名单`/etc/hosts.deny`中添加禁止列表。
  - 白名单`/etc/hosts.allow`中添加允许列表。


- 更改默认的22端口
  修改服务器的`/etc/ssh/sshd_config`文件中的`Port` 值为其他可用端口。

  如果要监听多端口，则注释掉`Port`行，添加`ListenAddress`：

  ```shell
  #Port 1234
  ListenAddress 0.0.0.0:22
  ListenAddress 0.0.0.0:222
  ListenAddress 0.0.0.0:2222 
  ```



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

      在`/etc/ssh/dedenyhostsny`中加上要禁止的用户名

  - 只允许某些用户登录

    在ssh配置文件中内容：

    - 允许单用户：`AllowUsers username`
    - 允许用户组：`AllowGroups groupname`（groupname是组名）

----

# 常用参数

- `p`：指定要连接的远程主机的端口
- `f`：成功连接ssh后将指令放入后台执行
- `C`：压缩所有数据
- `N`：不执行远程命令（不登录到服务器执行命令）
- `D`：动态端口转发
- `R`：远程端口转发
- `L`：本地端口转发
- `g`：（配合端口转发）允许远程主机连接到建立的转发的端口（不使用该参数则只允许本地主机建立连接）
- `t`：分配伪终端（可以用来执行任意的远程计算机上**基于屏幕的程序**）
- `T`：不分配TTY
- `A`：开启身份认证代理转发
- `q`：安静模式（不输出错误/警告）
- `v`：显示详细信息（可用于排错）

# 问题解决

- ssh命令中使用参数`-v`可输出详细的调试信息

- 各种登录失败问题
  - 确保`.ssh`文件夹权限为700，`authorized_keys`及公私钥文件的权限为`600`

    ```shell
    chmod 600 ~/.ssh/* && chmod 700 ~/.ssh
    ```

  - 客户端存在多个密钥对时，可能需要指定使用的私钥

    使用`-i`指定**私钥** ：

    ```shell
    ssh -i /path/to/private-key/ [-p port] user@host
    ```

  - ` REMOTE HOST IDENTIFICATION HAS CHANGED` 远程主机公钥未能通过主机密钥检查

    客户端首次登录ssh服务器时，客户端会记录服务器的公钥信息到`~/.ssh/known_hosts`（已知主机列表）文件中，每个主机一行。

    如果连接服务器时，服务器公钥与know_hosts列表中记录的公钥不同（例如远程主机更改了密钥），就会校验不通过。

    解决方案：
    - 删除客户端`.ssh/known_hosts`文件中检查不通过的ssh服务器的公钥信息
    - 关闭客户端的严格主机密钥检查(strict host key check)

    在`.ssh/config`（或`/etc/ssh/ssh_config`）中添加

    ```shell
    StrictHostKeyChecking no
    ```

    如果无需严格的主机密钥检查，也可以将已知主机信息文件指向`/dev/null`。

- `command not found` 执行远程命令提示找不到命令

  使用远程主机上的**非root用户**执行位于远程主机上`/sbin`（或`/usr/sbin/`）目录下的程序时，会提示"command not found"，解决方法：

  - 使用远程主机上的root用户执行

  - 如果该用户具有sudo权限，在命令前添加sudo执行

  - 使用绝对路径执行，例如：

    ```shell
  /usr/sbin/ip a
    /usr/sbin/lspci
    ```
  
- `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)`

  检查`/etc/ssh/sshd_config`是否关闭了密码登录。如需开启密码登录，修改该行：

  ```
   PasswordAuthentication no #注释该行或值改为yes 再重启sshd服务
  ```

- 协议不支持问题

  ssh版本过低引起，均可以升级服务器/客户端的ssh程序版本解决。

  - `no matching key exchange method found. Their offer: diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1`

    服务器ssh版本过低，不支持`diffie-hellman-group1-sha1`等协议。在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加：

    ```shell
  KexAlgorithms +diffie-hellman-group1-sha1
    ```
    
  - `no compatible cipher.The server supports these cipher:  aes128-ctr,aes192-ctr,aes256-ctr`

    ssh服务端不支持`aes128`等加密协议。在`/etc/ssh/ssh_config`或用户家目录的`~/.ssh/config`中添加：

    ```shell
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc
    ```

    
