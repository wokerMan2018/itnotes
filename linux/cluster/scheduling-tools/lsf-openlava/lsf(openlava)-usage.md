# 简介

LSF和openlava

> IBM Spectrum LSF是一款分布式集群管理系统软件，负责计算资源的管理和批处理作业的调度。

> openlava兼容IBM Spectrum LSF的工作负载调度器，支持各种高性能计算和分析应用。

# 资源信息

- host：主机（集群中的一个节点，一般是指一台单独的设备）

- queue：队列（同一类型的作业的集合，默认按作业提交的先后顺序排序执行，类似显示中的排队）

## 节点状态bhosts

- 节点信息

  ```shell
  lshosts  #各节点的系统信息（cpu内存等）
  
  bhosts  #各节点状态
  bhosts -l  <主机名>  #展示指定主机的信息
  
  lsload  #各节点的负载信息
  ```

  `bhost`的STATUS栏展示节点状态：

  - ok  可用——可接受新的作业的正常状态

  - unavail  不可用

    可能原因：主机关闭；LIM和sbatchd不可达。

  - unreach  无法连接

    可能原因：LIM在运行，但是sbatchd不可达。

  - close  关闭——不接受新的作业

    可能原因：该节点的最大作业数被设置为0；该节点被临时关闭；该节点正在运行的作业数量以达到上限。

    使用`bhosts -l 主机名`可查看具体原因。

- 开关节点

  ```shell
  badmin hopen  <主机名>
  badmin hclose <主机名>
  ```

## 队列信息

- 队列信息queues

  ```shell
  bqueues  #查看所有队列
  bqueues <队列名>  #查看某个具体队列的信息
  ```

- 开启或关闭队列

  ```shell
  badmin qopen <队列名>
  badmin qclose <队列名>
  ```

## 用户/用户组信息busers

展示用户和用户组相关信息，主要包括最大可用资源、当前运行作业数量、等待作业数量等。

```shell
busers all  #所有用户
busers <username>  #某个用户
buser  #当前用户
```

# 作业操作

JOB: 作业

## 提交作业bsub

root用户不能提交作业！

作业提交后，应检查一下作业的运行状况：ssh到作业运行节点，使用`top`等命令查看进程信息、处理器使用率、内存占用情况等。

---

```shell
bsub [参数] <命令>  #<命令>指要运行的命令/脚本/程序。

#最常用的参数组合如下
bsub -q <队列名> -m <机器名> -n <线程数> -o <标准输出文件> -e <标准错误输出文件> -J <作业名> <命令>

#提交示例
bsub sleep 100 #随机选择节点单线程执行

bsub -e %J.err -o %J.out -J myjob -n 16 mpiexec vasp  #16线程并行（mpiexec）执行vasp

bsub -m c01 -n 5 test.sh  #指定在c01执行test.sh

bsub -Ip vim testfile.txt  #分配一个节点用以打开vim
```

常用参数：

- `-q <队列名>`  指定要提交到的队列（可选）

  如不指定则提交到默认队列。

- `-m <节点名>`  提交到指定节点（可选）

  如不指定将随机选择合适的节点。

- `-n <线程数>`  指定使用的线程数（可选）

  如不指定默认为1。

  提示：该处`-n`指定的线程数是任务调度系统**分配给该作业的最大可用线程资源**，与该作业执行的程序是否多线程并行执行无必然联系，程序并行执行需要其自身进行并行调用操作。

  ```shell
  #虽然分配了8线程供其使用，但vasp_std是单线程执行
  bsub -n 8 vasp_std
  #分配了8线程资源 mpirun不带参数默认使用所有线程资源运行vasp_std
  bsub -n 8 mpirun vasp_std  #等同于#bsub -n 6 mpirun -n 8 vasp_std
  #为其分配了8线程资源 但mpirun指定只用4线程并行
  bsub -n 8 mpirun -n 4 vasp_std
  #只为其分配了8线程资源 mpirun要求超出可用资源范围
  bsub -n 8 mpirun -n 16 vasp_std
  ```

- `-o <标准输出文件>`  指定作业执行中的**标准输出**（stdout）信息文件（可选）

  如不指定，无标准输出文件。

  作业执行中的相关输出信息会写入该文件中，文件名字中可使用`%J`表示作业的编号（如`%J.txt`）。

- `-e <标准错误输出文件>`  指定作业执行中的**标准错误输出**（stderr）信息文件（可选）

  如不指定，无标准错误输出文件。

  作业执行中的相关**错误输出**信息会写入该文件中，文件名字中可使用`%J`表示作业的编号。

- `-J <作业名>`  指定作业名（可选）

  如不指定， 如不指定默认为提交作业执行的命令名。


- `-i`  指定作业的输入文件（需要指定作业输入文件时使用）
- `-Ip`  提交一个交互式作业并开启一个伪终端（交互式任务时必选）

## 查询作业

### bjobs和bhist查看作业记录

```shell
bjobs  #列出所有未完成作业
bjobs -r  #查看正在运行的作业
bjobs -p  #查看排队等待的作业
bjobs -d  #查看已经完成的作业

bjobs -u <username>  #查看某个用户的作业信息
bjobs -u all  #查看所有用户的作业

#加上作业编号可以查看某个具体的作业
bjobs 135  #查看135号作业（即使该作业已经完成也可以查看）
bjobs -l 135  #查看135号作业详情
bjobs -p 135  #查看处于排队状态的135号作业（可了解其排队原因）

bhist　#查看作业历史
bhist -a #查看所有历史提交的作业（包括未完成）
```

bjobs/bhist常用参数

这些参数后如不指定作业编号，将列出所有符合条件的所有作业的信息。

- `-r`  查看运行中（runing）的作业
- `-p`  查看排队中（pending）的作业
- `-d`  查看已完成（done）的作业
- `-l`  查看作业详情
- `-u`  查看某个用户的作业（如果值为`all`即查看所有用户的作业）

### bpeek查看运行中作业的输出

查看运行中作业的标准输出（stdout）和标准错误输出（stderr）。`

```shell
#bpeek查看正在运行的作业的输出信息
bpeek  #查看最近一个提交作业的输出信息
bpeek 135  #查看135号作业输出信息
```


### 作业状态

`bjobs`展示的状态信息中，STAT一栏为作业状态：

- DONE  已完成
- RUN     运行中
- PEND   排队等候调度
  - PSUSP  作业在排队中被挂起
  - USUSP  作业在计算中被挂起
  - SSUSP  作业被调度系统挂起

一个作业需要满足以下条件才能执行：

- 到达用户指定的时间（如果用户指定了开始时间）
- 合格的主机负载
- 队列中有符合执行条件的主机

### 常见排队原因

- > User has reached the pre-user job slot limit of the queue

  用户作业达到了排队中作业所在队列的**个人作业进程数上限。**

  此队列中用户正在运行的作业有计算结束，才会再分配后续的排队作业。

- > The slot limit reached; 4hosts

  排队中作业达到了所在队列**可使用节点数的上限。**

  此队列中所有用户正在运行的作业有计算结束，才会再分配此队列中排在最前边的作业。

- > The user has reached his job slot limit

  用于已运行的**作业数达到了系统规定的上限**。

  需已运行的作业有新的计算结束，排队中的作业才会进入系统调度。

- > The queue has reached its job slot limit

  队列中已经运行的所有作业达到了系统上**队列总作业进程数的上限**。

  需该队列中已运行的作业有新的计算结束，才会调度该队列中排在第一位的作业。

## 调整未完成作业

### 更改作业提交参数bmod

 只能在作业尚处于排队中时，已经运行的作业无法再更改提交或计算参数。

```shell
bmod -q high 123  #将123号作业编进名为high的队列中
bmod -J new_name 123  #给123号作业重新起名为new_name
```

### 更改作业执行顺序btop/bbot

**只能修改正在排列的作业**，对已经开始运行的作业无效。

```shell
btop 123  #将123号作业移动到排队的顶部
bbot 123  #将123号作业移动到排队的底部
```

### 挂起未完成作业bstop

```shell
bstop  <作业编号>
bstop 1234  #删除1234号任务
```

### 恢复挂起的作业bresume

```shell
bresume  <作业编号>
bresume 1234  #删除1234号任务
```

### 删除作业bkill

```shell
bkill  <作业编号>
bkill 1234  #删除1234号任务
```



# 程序管理

以下命令可能需要root（或sudo）用户才能执行。

```shell
lsid  #查看集群说明信息
#启动/停止程序
openlava start  #启动
openlava stop  #停止
openlava status  #状态
```

## 资源限制

资源管理配置文件`config/lsb.resources`，可调控用户在集群中可使用的资源配额。

可针对不同用户类型设置多种类型资源的使用限制。可配置的资源类型和用户类型如下：

- 资源类型（Resource types）
  - SLOT或SLOT_PER_PROCESSOR（工作槽）
  - MEM（内存）
  - SWP（交换空间）
  - TMP（临时空间）
  - JOBS（作业数量，包含RUN、SSUSP和USUSP[状态](#作业状态)的作业）
  - RESOURCE（其他共享资源）
- 用户类型（Consumer types）
  - USERS或PER_USER（用户）
    - `all`  所有用户
    - `user1 user2 ... userN`  指定的用户（以空格分隔）
  - QUEUES或PER_QUEUE（队列）
  - HOSTS或PER_HOST（主机）
  - PROJECTS或PER_PROJECT（项目）
  - LIC_PROJECTS或PER_LIC_PROJECT



限制策略示例：

```shell
Begin Limit  #限制策略开始标志
NAME=limit1  #限制策略的名字
PER_USER=all  #限制用于所有用户
SLOTS=10  #限制作业槽---一般等于cpu数量
End Limit  #限制策略结束标志
```

### 节点

- 增加节点

  1. 修改`/share/openlava/etc/lsb.hosts`配置文件，将新节点的`hostname`添加新节点到队列数组中

  2. 更新lsf配置

     ```shell
     lsadmin reconfig
     ```

  3. 在新计算节点上启动lsf相关服务

     ```shell
     source  /share/openlava/etc/openlava.sh
     /share/openlava/etc/openlava start
     ```

- 删改节点

参照增加节点的方法，删除和修改`/share/openlava/etc/lsb.hosts`配置，然后更新lsf配置。

## 配置