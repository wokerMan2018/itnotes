# 单次任务at

使用at执行任务前，确保atd.service已经启动。

```shell
systemctl start atd  #立即启动atd
systemctl enable atd  #开机atd自启动
```

-  语法：`at ·选项 参数 时间语句` 

  - 选项：

    - -f：指定包含具体指令的任务文件

    - -q：指定新任务的队列名称

    - -l：显示待执行任务的列表

      `at -l`是`atq`的别名，查看系统中其他尚未执行的命令，将显示任务列表，每一个任务有一个数字编号。

    - -d：删除指定的待执行任务

      `at -d`是`atrm`的别名，`atrm 任务编号`  删除某条未执行的任务。

    - -m：任务执行完成后向用户发送E-mail

    - -c ：连接命令行中列出的作业并输出到标准输出

      `at -c 数字`  显示某条未执行的任务内容

  - 时间语句示例：

    ```shell
    at 12:22
    at 17:00 tomorrow
    at now+30 miniutes
    at 10am+3 days
    ```

- 创建at任务

  - 使用脚本`at <时间语句> -f <脚本名>`

  - 使用交互式命令行

    1. 输入`at [选项 参数] 时间语句`，然后回车

    2. 输入要执行的命令

       注意：命令可能需要使用绝对路径

    3. 按下<kbd>Ctrl</kbd> <kbd>d</kbd>退出at交互式命令行

# 周期任务cron

cron有多个软件实现，如cronie、fcron、dcron等等。

1. 确保实现cron的服务已经运行（如ronie或crond）

2. `crontab -e`编辑周期任务列表

   cron列表每一行一个任务，书写格式：`分 时 日 月 星期 命令`

   - 分 值从 0 到 59.
   - 时 值从 0 到 23.
   - 日 值从 1 到 31.
   - 月 值从 1 到 12.
   - 星期 值从 0 到 6, 0 代表星期日

   通用符号：

   - `*`通配符匹配任意值
   - `-`连接符用在两个值之间表示一个时间段
   - `,`分隔符用在两个（多个）值之间表示两个（多个）时间点
   - `/`分隔符用在两个值之间表示间隔频率

   示例：

   ```shell
   * * * * * /usr/ls  #每分钟执行一次ls
   0 0 1 * * /usr/bin/reboot  #每月1日0时0分重启系统
   #每周三周六1点到3点和11点到13点每5分钟执行一次/home/test/update.sh
   *0,*5 1-3,11-13 * * 3,6 /home/test/update.sh
   ```

crontab其他参数或命令：

- -l  查看任务列表
- -r  移除任务列表
- -u  选择用户 （`crontab -u username -e` ）
- ` crontab -u username -e`   编辑其他用的任务列表 （username是其用户名）
- `export EDITOR="/usr/bin/nano" `  临时修改默认编辑器为nano  