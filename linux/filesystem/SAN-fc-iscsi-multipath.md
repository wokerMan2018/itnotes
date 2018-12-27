> **iSCSI**（Internet Small Computer System Interface，发音为/ˈаɪskʌzi/），互联网小型计算机系统接口，又称为IP-[SAN](https://zh.wikipedia.org/wiki/SAN)，是一种基于[因特网](https://zh.wikipedia.org/wiki/%E5%9B%A0%E7%89%B9%E7%BD%91)及[SCSI-3](https://zh.wikipedia.org/wiki/SCSI-3)协议下的存储技术。

# iscsi

1. 安装iscsi软件包，启动`iscsi`服务。

2. 查找

   ```shell
   iscsiadm -m discovery -t sendtargets -p <ip>  #sendtargets可缩写为st
   #---
   iscsiadm -m discovery -p <ip> -o delete  #删除旧的目标
   iscsiadm -m node --op delete  #删除所有目标
   ```

3. 登录

   ```shell
   iscsiadm -m node -L all  #登入到有效的目标
   iscsiadm -m node --targetname=<targetname> --login  #登录到指定目标
   #---
   iscsiadm -m node -U all  #登出
   iscsiadm -m node -T <targetname> -p <ip> #登出指定目标
   ```

   查看登录目标的信息

   ```shell
   iscsiadm -m node
   ```

4. 挂载

   使用`lsblk`从块设备中发现存储设备，将其挂载即可。

   多路径挂载参看[多路径配置](#多路径配置)。

# FC

> **网状通道**（**Fibre Channel**，简称**FC**）是一种高速网络互联技术，SAN中的一种常见连接类型。

1. 连接

   连接服务器和存储后，存储端需要设置主机映射，映射时需要获取WWN(WWPN/WWNN）编号，该值可从`/sys/class/fc_host/host*/port_name`（主要一般不包括前面的`0x`）。

   ```shell
   #查看wwn
   cat /sys/class/fc_host/host*/port_name
   #查看连接状况
   cat /sys/class/fc_host/host*/port_state
   #查看连接类型
   cat /sys/class/fc_host/host*/port_type
   ```

2. 挂载

   使用`lsblk`从块设备中发现存储设备，将其挂载即可。

   ```shell
   #扫盘（如果已经映射而未在快设备列表发现）
   echo "- - - " > /sys/class/fc_host/host*/scan
   #注意 如果没有scan文件则
   echo "1" > /sys/class/fc_host/host*/issue_lip
   lsscsi
   ```

   多路径挂载参看[多路径配置](#多路径配置)。

# 多路径配置

由iSCSI组成的IP-SAN环境中或光纤组成的FC-SAN环境中，主机和存储通过了光纤交换机或者**多块网卡及多个IP来连接**，构成了**多对多**的关系，主机到存储可以有多条路径可以选择。

操作系统认为每条路径各自通一个物理盘，但实际上这些路径只通向同一个物理盘，这种情况下需要配置多路径。

> 多路径的主要功能就是和存储设备一起配合实现如下功能：
> 1.故障的切换和恢复
> 2.IO流量的负载均衡
> 3.磁盘的虚拟化

安装多路径软件包`device-mapper-multipath`，启动`multipath`服务。

配置多路径文件，挂载多路径设备：

```shell
#自动配置 配置内容在/etc/multipath/目录下
mpathconf --enable --with_multipathd y

#查看多路径设备并挂载
lsblk
mkfs.xfs /dev/mapper/mpatha  #假如多路径为mpatha
mkdir /data
mount /dev/mapper/mpatha /data
#写入开机自动挂载
echo "/dev/mapper/mpatha /data xfs _netdev,defaults 0 0" >> /etc/fstab
#或使用uuid
#echo "UUID=`lsblk -o uuid /dev/mapper/mpatha |grep -iv uuid` /data xfs _netdev,defaults 0 0" >> /etc/fstab
```

块设备列表中**type**为**mpath**的块设备即为多路径设备，相同名字的块设备（如`mpatha`）即配置了多路径的同一存储设备，其位于`/dev/mapper/`下。



---

如果不能使用自动配置，可使用`multipath -F`生成文件模板，参照模板配置。

配置示例：

```shell
blacklist {
    devnode "^sda"  #将非多路径的块设备排除
}
defaults {
    user_friendly_names yes
    path_grouping_policy multibus
    failback immediate
    no_path_retry fail
}
```

重启`multipath`服务，查看多路径情况，按需要挂载。

```shell
multipath -ll  #查看多路径服务情况
lsblk
```

配置排错

```shell
multipathd -k #进入交互模式，具体请查看 man multipathd
>list|show config
>reconfigure
>list|show path
```

