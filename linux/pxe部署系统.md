> 预启动执行环境（Preboot eXecution Environment，PXE，也被称为预执行环境)提供了一种使用网络接口（Network Interface）启动计算机的机制。这种机制让计算机的启动可以不依赖本地数据存储设备（如硬盘）或本地已安装的操作系统。

PXE 协议在启动过程分为 client 和 server 端，以下以centos7.x为例，假设DHPC、TFTP和web镜像服务均由一台主机提供，称之为部服务器，其余要被部署系统的设备称为客户端。

PXE 协议运行过程主要解决两个问题：首先解决 IP 地址的问题，然后解决如何传输操作系统启动文件和安装文件的问题。

# 准备

相关准备工作。

- 确保客户端和服务器的网络物理连接正确（网线直连/交换机）

- 客户端根据需求进行相关操作，一般有：

  - 搜集各个客户端的使用的网卡的MAC地址

    在需要按设备摆放位置顺序进行IP分配的情况下很有必要，方便后续管理。

  - 具有RAID卡的设备如需使用RAID，需要配置好RAID。

  - BIOS中其他相关设置。

- 操作系统镜像文件

- 服务器相关配置：

  - IP地址

    使用静态地址，本文假定的相关配置如下：

    ```shell
    BOOTPROTO=static
    IPADDR=192.168.0.251
    NETMASK=255.255.255.0
    GATEWAY=192.168.0.254
    ONBOOT=yes
    ```

  - hosts文件

    可将要安装的客户端的hostname解析写在`/etc/hosts`，以便dnsmasq自动分配hostname。

  - 关闭（或者配置相关策略）`selinux`和`firewalld`方便后续部署工作

    ```shell
    setenfore 0
    systemctl stop firewalld  #如果使用的iptables则关闭iptables
    ```

# 安装配置相关工具

## DHCP和TFTP--dnsmasq

dnsmasq包含dhcp、dns和tftp功能，无需单独安装配置这三种工具。

1. 安装和启用dnsmasq服务。

2. 配置dnsmasq，配置文件`/etc/dnsmasq.conf`示例：

   ```shell
   port=0  #设置为0表示不适用dns功能
   #interface=eth0  #监听的网口 不配置表示不特别指定
   #listen-address=::1,127.0.0.1,192.168.0.88
   bind-interfaces
   
   dhcp-range=192.168.0.50,192.168.0.150,infinite  #dhcp地址池、租期
   #dhcp-host=00:0C:29:F6:07:CA,192.168.88.165,compute1  #静态绑定
   #dhcp-host=00:0C:29:5E:F2:3F,ignore  #忽略这个mac地址的dhcp请求
   
   dhcp-host=judge # 通过/etc/hosts来分配对应的hostname
   #no-hosts  #如果不启用本地解析文件(/etc/hosts)就去掉注释
   #add-hosts=/etc/add_hosts #增加自定义hostname解析文件（类似/etc/hosts）
   
   enable-tftp  #启动tftp
   tftp-root=/mnt/pxe  #tftp目录
   dhcp-boot=pxelinux.0  #bootstrap启动程序
   ```

## web服务器--darkhttpd

安装`darkhttpd`，执行`darkhttpd <系统文件根目录路径>`即可，默认监听8080端口。

例如：

```shell
darkhttpd /mnt/pxe
#darkhttpd --port 80 /mnt/pxe  #使用--port制定监听端口
```

## 系统相关文件

1. 从系统镜像文件中，将系统内核镜像`initrd.img`和文件系统镜像`vmlinuz`放置到tftp根目录（也可以直接将内核/文件系统镜像所在目录作为tftp根目录。

2. pxe启动文件pxelinux.0

   centos/rhel可以安装`syslinux`，然后将`/usr/share/syslinux/pxelinux.0` 复制到tftp根目录。

   针对UEFI还需要： 

   ```shell
   rpm2cpio /centos/Packages/shim-0.9-2.el7.x86_64.rpm | cpio -dimv
    rpm2cpio /centos/Packages/grub2-efi-2.02-0.44.el7.centos.x86_64.rpm | cpio -dimv
   ```

   上面命令将在当前目录生成一个boot目录，复制boot/efi/EFI/centos中的`shim.efi`和` grubx64.efi`文件到tftp根目录。

3. 引导文件pxelinux.cfg

   - legacy引导

   - 从镜像中复制isolinux.cfg文件到tftp根目录改为了pxelingu.cfg，修改如下内容

     ```shell
     default linux
     prompt 1
     timeout 60
     display boot.msg
     label linux
       kernel vmlinuz
       append initrd=initrd.img text ks=http://192.168.0.3/ks.cfg 
     ```

   - efi引导






## 自动化安装系统--kickstart（可选）

红帽公司开发的kickstart工具，以自动化安装方式代替传统交互式安装方式。

kickstart的配置文件（以下称为`ks.cfg`）中含有系统安装时各种配置参数，可参照[创建 Kickstart 文件](#https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/6/html/installation_guide/s1-kickstart2-file)手册编写配置文件，此外还可按以下方式取得配置文件kc.cfg：

- 手动安装的rhel/centos系统的/root家目有`anaconda-ks.cfg`文件可供参考。

  注意：kickstart文件中含有root管理员及其他用户（如果安装时创建过这些用户）密码（安装时设置的密码），因此在安装完成后务必修改用户密码或保存好`/root`目录下的kickstart文件。

- 使用图形界面工具`system-config-kickstart`生成。

可安装` pykickstart`用以验证ks文件的正确性。

```shell
ksvalidator ks.cfg  #如果没任何输出则表示没有问题
ksverdiff -f RHEL6 -to RHEL7  #在CentOS 7系统查看CentOS 6与7的ks版本区别
```

ks.cfg示例

```shell
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512

# OS Source
url --server=172.168.0.251:80/repo/os
#nfs --server=172.168.0.251 --dir=/srv/repo/os

# Installation Interface
graphical
#text

# Run the Setup Agent on first boot
firstboot --disable

#specify the disk
#ignoredisk --only-use=vda

# Keyboard layouts
keyboard --vckeymap=cn --xlayouts='cn'

# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp -activate
network  --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$kkI9j/.nisdh3daI$eAcsvC34kNsaPiA75EhClwLpN5c1xVL.DXVnXqwI4oAd9/ARhVyLjvh3LSTBsFq6Ctn3qF8qkrqCT2GEH9pbA0
# System services
services --enabled="chronyd"
# System timezone
timezone Asia/Shanghai --isUtc
# X Window System configuration information
xconfig  --startxonboot
# License agreement
eula --agreed
# System bootloader configuration
bootloader --location=mbr --boot-drive=vda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^gnome-desktop-environment
@base
@core
@desktop-debugging
@dial-up
@directory-client
@fonts
@gnome-desktop
@guest-agents
@guest-desktop-agents
@input-methods
@internet-browser
@java-platform
@multimedia
@network-file-system-client
@networkmanager-submodules
@print-client
@x11
chrony

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
```

