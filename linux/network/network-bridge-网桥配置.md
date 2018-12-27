[TOC]

> **桥接器**（英语：network bridge），又称**网桥，**将[网络](https://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C)的多个[网段](https://zh.wikipedia.org/wiki/%E7%BD%91%E6%AE%B5)在[数据链路层](https://zh.wikipedia.org/wiki/%E6%95%B0%E6%8D%AE%E9%93%BE%E8%B7%AF%E5%B1%82)（[OSI模型](https://zh.wikipedia.org/wiki/OSI%E6%A8%A1%E5%9E%8B)第2层）连接起来（即桥接）。



*示例中，网桥名为`br0` ，有线网卡设备名为`eth0` ，无线网卡设备名为`wlo1`（网卡设备名可使用`ip addr`命令查看）。*

# brctl

需要安装`bridge-utils` 。

- 创建流程：

  1. 创建网桥

     ```shell
     brctl addbr br0
     ```

  2. 添加一个设备到网桥

     ```shell
     brctl addif br0 eth0
     ```

  3. 启动网桥

     ```shell
     ip link set up dev br0
     ```

  4. 分配ip地址

     ```shell
     ip addr add dev br0 192.168.10.100/24
     ```

- 其他常用命令

  bridge-utils的命令格式是`brctl [commonds]` ，更多命令查看`brctl --help` 。

  - 显示当前已存在的网桥`brctl show`

  - 删除网桥`delbr`

    ```shell
    ip link set dev br0 down  #删除网桥前先关闭启动的网桥
    brctl delbr br0  #删除名为br0的网桥
    ```

# ip命令

需要安装`iproute2`。

- 创建流程：

  1. 创建网桥

     ```shell
     ip link add name br0 type bridge
     ```

  2. 启动网桥

     ```shell
     ip link set up dev br0
     ```

  3. 添加一个设备到网桥

     ```shell
     ip link set dev eth0 promisc on  #将该端口设置为混杂模式
     ip link set dev eth0 up  #启动该端口
     ip link set dev eth0 master br0  #将该端口添加到网桥中
     ```

  4. 分配ip地址

     ```shell
     ip addr add dev br0 192.168.10.100/24
     ```

- 其他命令

  - 显示当前已存在的网桥 `bridge link show`  （ bridge 工具包含在iproute2中）

  - 删除网桥

    ```shell
    ip link set eth0 promisc off  #关闭端口混杂模式
    ip link set eth0 down  #关闭端口
    ip link set dev eth0 nomaster  #恢复该端口设置（创建是设置了master）
    ip link delete br0 type bridge  #删除网桥br0
    ```

注意：创建的网桥在重启系统后就不存在了，可以但创建网桥的命令写成脚本放到/etc/profile.d下令其在系统启动后自动创建。