TCP/IP网络性能的测试工具

> netperf基于C/S（client-server）模型设计。netserver运行在目标服务器上，netperf运行在客户机上。netperf控制netserver，netperf把配置数据发送到netserver，产生网络流量，从一个独立于测试连接的控制连接获取netserver的结果。在测试过程中，在控制连接中没有数据交流，所以不会对结果产生影响。netperf压测工具也有提供报表的功能，包括CPU使用率。

全局选项：

    -A 设置本地接收和发送缓冲的调整

    -b 爆发大量流测试包

    -H 远程机器

    -t 测试流量类型
        TCP_STREAM 大量数据传输测试
        TCP_MAERTS 和TCP_STREAM很像，只是流的方向相反
        TCP_SENDFILE 和TCP_STREAM很像，只是使用sendfile()，而不是send()。会引发zero-copy操作
        UDP_STREAM 和TCP_STREAM很像，只不过是UDP
        TCP_RR 请求响应报文测试
        TCP_CC TCP的连接/关闭测试。不产生请求和响应报文。
        TCP_CRR 执行连接/请求/响应/关闭的操作。和禁用HTTP keepalive的HTTP1.0/1.1相似。
        UDP_RR 和TCP_RR一样，只不过是UDP。

    -l 测试长度。如果是一个正值，netperf会执行testlen秒。如果值为负，netperf一直执行，直到大量数据传输测试中交换testlen字节，或者在请求/响应次数达到testlen。

    -c 本地CPU使用率报告

    -C 远程服务器CPU使用率报告

    在某些平台上，CPU使用率的报告可能不准确。在性能测试之前，请确保准确性。

    -I 这个选项是用来维护结果可信度的。可信级别应该设置为99%或者95% 。为了保证结果可信度级别，netperf会把多次重复测试。例如-I 99 5，代表在100次的99次中，测试结果和真实情况有5%（+-2.5%）的浮动区间。

    -i 这个选项限制了最大和最小的重复次数。-i 10 3表示，netperf重复同样的测试，最多10次，最少3次。如果重复次数超过最大值，结果就不在-I指定的可信任级别中，将在结果中显示一个警告。

    -s , -S 修改发送和接收的本地和远程缓冲大小。这个会影响到窗口大小。

TCP_STREAM,TCP_MAERTS,TCP_SENDFILE,UDP_STREAM的选项

    -m , -M 指定传给send()和recv()函数的缓冲大小。分别控制每个调用的发送和接收大小。

TCP_RR,TCP_CC,TCP_CRR,UDP_RR的选项：

    -r ,-R 分别指定请求和响应的大小。例如-r 128,8129意思是netperf发送128字节包到netserver，然后它响应一个8129字节的包给netperf。

