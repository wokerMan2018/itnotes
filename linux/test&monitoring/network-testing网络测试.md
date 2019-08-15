# 监控工具

- iftop
- nethogs
- nload

- [mtr](#mtr)

# 测试工具

## 网络可用性测试

主要用以监测和诊断网络是否连通。

### ping

`ping <host>`

### ibping

Infiniband 网络测试，一般附带在Infiniband套件中，比通常的Ping功能更多。

### curl

ping被禁止时可以用curl检查端口的可用性

`curl <host>:<port>`

### telnet

`telnet <host> <port>`

## 路由追踪

### traceroute和tracepath

用于追踪并显示报文从数据源（source）主机到达目的（destination）主机所经过的路由信息，给出网络路径中每一跳（hop）的信息。

traceroute专门用户追踪路由，追踪速度更快；tracepath可以检测MTU值。

另*windows下有tracert*。

```shell
tracepath [-n] z.cn
traceroute z.cn
```

### mtr

mtr是My traceroute的缩写，是一个把ping和traceroute并入一个程序的网络诊断工具。

直接运行`mtr`会进入ncurses编写的实施监测界面。此外还有该工具的其他图形界面前端实现，如mtr-gtk。

```shell
mtr --report -c 10 -n z.cn  #检测z.cn的traceroute
```

## 网络性能测试

### iperf和netperf

二者均是客户端-服务端模式（C/S client-server），先在服务端开启监听服务，然后客户端向服务端发起连接。

简单示例（更多参数查看帮助）：

- iperf

  - 服务端：`iperf -s `
  - 客户端：`iperf -c <server> `

  ```shell
  iperf -s [-p port] [-i 2]  #p监听的端口 i报告刷新时间间隔
  iperf -c <server> [-p port] [-i 2] [-t 10]  #t测试总时间
  ```

- netperf

  - 服务端：`netserver `
  - 客户端：`netperf -H <server>`

  ``` shell
  netserver [-p port] [-L localip]  #p端口 L本地ip
  netperf -H <server> [-p port] [-m send_data_size] [-l total_time] #m发送数据大小  l测试总时间
  ```

  

