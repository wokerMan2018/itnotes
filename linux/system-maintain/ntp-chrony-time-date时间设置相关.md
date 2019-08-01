# 时间相关知识

## 时区

Time Zone  时区

- UTC  协调世界时（协调通用时间） **C**oordinated **U**niversal **T**im

  为世界标准，来自原子钟。

- G.M.T.  格林威治标准时间  **G**reenwich **M**ean **T**ime

  为十七世纪格林威治皇家天文台确立，以本初子午线时间为标准，日常普通使用中可理解为与UTC一致。

- CST  根据设置的时区不同，其有不同的意义。
  - 中华地区
    - 中国标准时间  **C**hina **S**tandard **T**ime
    - 中原标准时间  **C**hungyuan **S**tandard **T**ime
  - 北美中部时间  **C**entral **S**tandard **T**ime (North America)
  - 澳洲中部时间  **C**entral **S**tandard **T**ime (Australia)
  - 古巴标准时间  **C**uba **S**tandard **T**ime
- PST  太平洋时间
- DST  日光节约时制Daylight saving time，即夏令时（夏时制）  Summer time。

## 硬件时钟与系统时钟

- 硬件时钟，即硬件实时时钟**RTC** (**R**eal-**T**ime **C**lock)或CMOS 时钟，主板上BIOS中的时间，由主板电池供电来维持运行。硬件时间保存的时间信息有：年、月、日、时、分、秒。

- 系统时钟（或称软件时间），即本地时间**L**ocal **T**ime。系统启动之后，系统时钟与硬件时钟独立运行，Linux 通过时钟中断计数维护系统时钟。保存的时间信息有：时间、时区和夏令时设置。

  大部分操作系统以如下方式管理时间信息： 

  - 启动时根据硬件时钟设置；
  - 运行时如果配置有时间同步服务，则同步时间服务器的时间；
  - 关机时根据系统时间设置硬件时间。

# 时间相关常用命令

## time、times和timeout

- time  统计指定命令执行所耗费的时间

  ```shell
  time ls
  ```

  输出的信息包含：

  - real时间：命令开始执行到结束执行所耗费的时间，包括其他进程所占用的时间片，和进程被阻塞时所花费的时间。
  - user时间：耗费在用户模式中的CPU时间，唯一真正用于执行进程所花费的时间，不包含其他进程和花费阻塞状态中的时间。
  - sys时间：耗费在内核模式中的CPU时间，代表在内核中执系统调用所花费的时间，为**真正由进程使用的CPU时间**。

- times  显示进程时间

   打印 shell 及其所有子进程的累计用户空间和系统空间执行时间，退出码总是0。

  ```shell
  times <command>
  ```

- timeout  若指定运行的命令在指定的时间后仍在运行则将其中止。

  ```shell
   timeout 5 ping z.cn
   timeout -s HUP 10  du -sh *  #注意时间要写在timeout的选项之后，在执行命令之前
  ```

## hwclock

硬件时钟(hardware clock)

```shell
  #读取硬件时钟的时间
  hwclock -r  #或 hwclock --show
  #当前系统时间写入硬件时钟
  hwclock -w #或 hwclock--systohc
  #将系统时间写入硬件实时时钟，且使用了UTC时间作为标准
  hwclock -w -u #-u也可写为--utc
  
  #校准时间漂移
  hwclock -a  #或 hwclock --adjust）
```

## date

系统时间

```shell
date
#时间相关设置情况 包括本地时间、通用时间、硬件时钟、时区、NTP启用情况等
date -s "2046-10-24 10:10"
```

## tzselect

```shell
#设置时区
tzselect  #按提示进行时区选择
#也使用以下命令  (以Asia/Shanghai为例)
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## timedatectl

```shell
timedatectl  #查看时间设置相关信息
timedatectl set-ntp true  #开启时间同步
timedatectl set-time <time string>  #设置时间
timedatectl set-timezone <time zone>  #设置时区
```

# 网络时间同步服务

常见实现ntp（网络时间协议）的工具有chrony和ntp。

另有图形界面工具如`system-config-date`等。

如果开启了防火墙，需要放行NTP的端口：

```shell
firewall-cmd --add-service=ntp --permanent
firewall-cmd --reload
```

## chrony

安装`chrony`并启用`chronyd`服务

配置`/etc/chrony.conf`示例：

```shell
#时钟服务器
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 127.127.1.1 prefer  #chrony中使用本机时间 127.127.1.1
allow all

#同步源的层级
stratumweight 0
#存储校准漂移信息的文件
driftfile /var/lib/chrony/drift
#其将启用一个内核模式，系统时间每11分钟拷贝到实时时钟（RTC）
rtcsync
#调整策略：当调整期大于某个阀值时，调整系统的时钟
makestep 1.0 3

#允许和禁止与本机同步的客户端
#allow 192.168.4.5
#deny 192.168/16

#允许和禁止使用命令控制的客户端
#allow 192.168.4.5
#deny 192.168/16

#限制仅本机使用命令控制chrony服务器
bindcmdaddress 127.0.0.1
bindcmdaddress ::1

keyfile /etc/chrony.keys
commandkey 1
generatecommandkey
noclientlog
logchange 0.5
logdir /var/log/chrony
```

以上配置项多为服务端使用，作为户端，一般只设置server即可。

```shell
server master #master为服务端主机名（或使用ip地址）
```

---

**chronyc**是用来监控chronyd性能和配置其参数的用户界面。

```shell
sudo hwclock -s -u #将rtc时钟时间设为系统时间并使用utc
```

常用chronyc命令对象（（可直接附在chronyc命令后，也可以进入chronyc命令行界面使用）：

- makestep 手动校准
- tracking  系统时间信息
- sources  查看同步源信息
  - -v  查看更详细信息
- sourcestats 查看同步源的状态
- activity  查看处于活动状态的同步源
- accheck  检查NTP访问是否对特定主机可用
- clients  查看客户端
- settime 设置为指定时间
- delete 删除指定客户端
- add server 添加服务器

## ntp

安装`ntp`包并启用`ntpd`服务。

配置`/etc/ntpd.conf`示例：

```shell
#禁止该主机查询时间
restrict 192.168.0.251 noquery
##禁止该网段来源的主机修改时间
restrict 192.168.0.0 mask 255.255.255.0 nomodify

#限制权限
restrict 127.0.0.1
restrict -6 ::1     #ipv6使用

#同步时间的服务器
#server 0.arch.pool.ntp.org
#server 1.arch.pool.ntp.org prefer #prefer者优先

#注意，如果采用本机内部时钟 使用127.127.1.0而非127.0.0.1
server 127.127.1.0
#设置本地时间源的层数（最大15)
fudge  127.127.1.0 stratum 10

#该主机频率与上层时间服务器的频率
driftfile /var/ntp/driftfile
```

以上配置项多为服务端使用，作为户端，一般只设置server即可。

```shell
server master #master为服务端主机名（或使用ip地址）
```

常用命令

```shell
#查看ntp同步状态
ntpq -pn
#监控同步状态 （其中reach一项的值增加到17时同步完成）
watch ntpq -p
#手动同步 
ntpdate <time-server>
```

---

- server服务器信息

  ```shell
  server host  [key n] [version n] [prefer] [mode] [minpoll] [maxpoll n] [iburst]
  ```

  - key： 表示所有发往服务器的报文包含有秘钥加密的认证信息，n是32位的整数，表示秘钥号。
  - version： 表示发往上层服务器的报文使用的版本号，n默认是3，可以是1或者2。
  - prefer： 如果有多个server选项，具有该参数的服务器有限使用。
  - mode： 指定数据报文mode字段的值。
  - minpoll： 指定与查询该服务器的最小时间间隔为2的n次方秒，n默认为6，范围为4-14。
  - maxpoll：  指定与查询该服务器的最大时间间隔为2的n次方秒，n默认为10，范围为4-14。
  - iburst： 当初始同步请求时，采用突发方式接连发送8个报文，时间间隔为2秒。

- restrict对客户端权限进行限制

  ```shell
  restrict <ip> [mask <netmask>] [parameter]
  ```

  parameter取值：

  - ignore： 拒绝所有类型的 NTP 联机
  - nomodify： 客户端不能使用 ntpc 与 ntpq 这两支程序来修改服务器的时间参数
  - noquery： 客户端不能够使用 ntpq, ntpc 等指令查询时间服务器
  - notrap： 不提供 trap 这个远程事件登录 (remote event logging) 的功能
  - notrust： 拒绝没有认证的客户端
  - nopeer：提供时间服务，但不作为对等体。
  - kod：向不安全的访问者发送Kiss-Of-Death报文

  ### ntp服务其他模式

  ntp服务除了上面最常使用的”服务端-客户端（server-client)“模式外，还有：

  - 对等体模式 peer：如果双方的时钟都已经同步，则以层数小的时钟为准。

    服务端和客户端均使用peer

    ```shell
    peer [地址] [prefer]
    ```

  - 广播模式 broadcast

    服务端：

    ```shell
    broadcast 192.168.1.255 autokey
    ```

    客户端：

    ```shell
    broadcastclient [地址]
    ```

    - 组播模式multicast

      服务端：

      ```shell
      broadcast 192.168.1.255 autokey
      ```

      客户端：

      ```shell
      multicastclient [地址]
      ```

    - 多播（选播）模式manycast
      服务端：

      ```shell
      broadcast [地址] autokey
      ```

      客户端：

      ```shell
      multicastclient [地址]
      ```

  - 主动-被动模式

    主机互为服务端和客户端。（多用于集群中）\
