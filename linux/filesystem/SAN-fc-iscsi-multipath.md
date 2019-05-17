> **iSCSI**（Internet Small Computer System Interface，发音为/ˈаɪskʌzi/），互联网小型计算机系统接口，又称为IP-[SAN](https://zh.wikipedia.org/wiki/SAN)，是一种基于[因特网](https://zh.wikipedia.org/wiki/%E5%9B%A0%E7%89%B9%E7%BD%91)及[SCSI-3](https://zh.wikipedia.org/wiki/SCSI-3)协议下的存储技术。

# iscsi

1. 安装iscsi软件包，启动`iscsi`服务。

2. 获取或设置`/etc/iscsi/initiatorname.iscsi`中的InitiatorName

   initiatiorname提供给iscsi存储服务器端用以映射主机时使用。

   根据需要修改该配置文件的设置项。

3. iscsi发现和登录

   ```shell
   #获取iscsi目标 sendtargets可缩写为st  端口默认为3260时可省略
   iscsiadm -m discovery -t st -p <iscsci-server>[:port]
   #指定要登录的目标
   iscsiadm -m node -T <target-name> -p <iscsi-server>[:port] --login
   ```

   在发现**一个**目标后，也可以使用`session`直接注册登录，而无需指定target等参数：

   ```shell
   iscsiadm -m discovery -t sendtargets -p <iscsci-server>[:port]
   iscsiadm -m node -l
   iscsiadm -m session
   #再重复以上步骤添加下一个目标
   ```

   或者添加多个target后使用以下命令登录到所有目标：

   ```shell
   iscsiadm -m node -L all  #登入到有所有效的目标
   ```

   

   其他相关命令

   ```shell
   iscsiadm -m discovery -p <ip> -o delete  #删除旧的目标
   iscsiadm -m node --op delete  #删除所有目标
   #登出某个目标
   iscsiadm -m node -T <target-name> -p <iscsi-server>[:port] --logout
   iscsiadm -m node -U all  #登出所有
   iscsiadm -m node  #查看登录目标的信息
   ```

4. 挂载

   使用`lsblk`从块设备中发现存储设备，将其挂载即可。

   提示：在fstab中添加挂载网络存储设备，应当添加`_netdev`参数，避免因网络未就绪而造成挂载失败。

   ```shell
   #建议使用UUID挂载 可使用lsblk /dev/mapper/xxx -o uuid获取
   UUID='xxx'    /data    xfs     _netdev,defaults,discard  0 0
   ```

   如仍有挂载问题，可考虑在启动后延时挂载（检查测网络可到达后再挂载）。

   如需要多路径挂载，参看[多路径配置](#多路径配置)。

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



配置多路径

- 自动配置命令

  ```shell
  mpathconf --enable --with_multipathd y
  ```

- 手动配置

  修改`/etc/mpath.conf`（可使用`multipath -F`生成文件模板文件作参考）。

  示例1，指定多路设备并进行配置：

  wwid可使用`multipath -ll`获取。

  ```shell
  devices {
  	device {
  		vendor "COMPELNT"
  		product "Compellent Vol"
  		features 0
  		no_path_retry fail
  		}
  	}
  multipaths {
  	multipath {
  		wwid "36000d310045794000000000000000003"
  		alias "data"
  		uid 0
  		gid 0
  		mode 0600
  		}
  	}
  ```

  示例2，使用黑名单方式排除非多路径设备：

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



挂载多路径设备

```shell
#查看
lsblk -f |grep mpath #type为mpath_member
#创建文件系统
mkfs.xfs /dev/mapper/mpatha  #假如多路径为mpatha
#挂载
mkdir /data
mount /dev/mapper/mpatha /data

#写入开机自动挂载（建议使用UUID）
echo "UUID=`lsblk -o uuid /dev/mapper/mpatha |grep -iv uuid` /data xfs _netdev,defaults 0 0" >> /etc/fstab
```

重启`multipath`服务，查看多路径设备情况。

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

