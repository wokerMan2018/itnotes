[TOC]

# 简介

# docker与容器技术

docker是一种Linux 容器（Linux Containers，缩写为 LXC）解决方案。

容器Contanier将运行环境打包，提供标准的接口，能够运行在众多操作系统上。

> **容器使软件具备了超强的可移植能力。**

容器由两部分组成：应用程序本身和依赖。

容器在宿主机操作系统的用户空间中运行，与操作系统的其他进程隔离。

> 传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程；而容器内的应用进程直接运行于**宿主的内核** ，**容器内没有自己的内核，而且也没有进行硬件虚拟**。因此容器要比传统虚拟机更为轻便。

docker基础镜像（base images，如各个发行版的基础镜像）使用的是**宿主机的内核**。在对内核版本有要求（比如应用只能在某个 kernel 版本下运行）的情况下，虚拟机可能更合适。

## docker的架构

- 客户端Client：构建和运行容器。

- 镜像Image：容器的只读模板，通过镜像构建容器。
- 容器Container：镜像的运行实例。
- 服务daemon：创建、运行、监控容器，构建、存储镜像。
- 仓库Repository：存放镜像

# 安装配置

- 安装docker

  提示：windows专业版和企业版用户开启hyper-V；windows家庭版用户无hyper-V，只能使用[docker toolbox](https://docs.docker.com/toolbox/)。

- 启用docker服务`systemctl start docker`

## 修改镜像源

Linux/Mac修改 `/etc/docker/daemon.json`，windows（安装docker的专业版和企业版）修改`%programdata%\docker\config\daemon.json`，示例：

```shell
{
  "registry-mirrors": ["源地址"]
}
```

安装docker toolbox的windows：

1. 开启docker quickstart terminal，执行：

   ```shell
   docker-machine ssh default
   ```

2. 向`/var/lib/boot2docker/profile`文件中添加源（使用`sudo`）：

   > EXTRA_ARGS='|EXTRA_ARGS='--registry-mirror=源地址

3. 退出后重启docker，执行以下命令：

   ```shell
   exit
   docker-machine restart default
   ```

## 非root用户使用docker

要将该用户添加到docker组中：

```shell
usermod -aG docker <username> #或 gpasswd -a <username> docker
#重新登入系统或使用以下命令使其立即生效：
newgrp docker
```

## 修改存放目录

默认情况下，Docker镜像和容器的默认存放位置为:`/var/lib/docker`，可使用`docker info | grep 'Root Dir'`命令查看。

假如要设定的存放路径为`/home/docker/` ，可使用以下方法：

- 使用软链接

  ```shell
  systemctl stop docker  #如果docker服务正在运行 先关闭之
  mv /var/lib/docker /home/docker  #移动docker存放文件
  ln -sf /home/docker /var/lib/docker  #将新位置软连接到原来的存放位置
  ```

- 修改全局配置文件

  各个操作系统中的存放位置不一致， Ubuntu 中的位置是：`/etc/default/docker`，在 CentOS 中的位置是：`/etc/sysconfig/docker`。在配置文件中添加：

  ```shell
  OPTIONS=--graph="/root/data/docker" -H fd://
  #如果系统有selinux并已经开启，可添加关闭selinux的参数
  OPTIONS=--graph="/root/data/docker" --selinux-enabled -H fd://
  ```

## docker信息

- 查看docker状态`docker info`
- 查看镜像、容器、数据卷所占用的空间`docker system df`

# 镜像操作

- 列出本地镜像`docker images`

  - 虚悬镜像`docker image ls -f dangling=true`

    由于新旧镜像同名，旧镜像名称会被取消，从而出现仓库名、标签均为 `<none>` 的镜像。

- 删除镜像

  ```shell
  docker image rm <image>[:tag]  #或者docker image rm <镜像id>
  docker rmi <image>[:tag]   #rmi只能删除 host 上的镜像，不会删除 registry 的镜像
  ```


## 从仓库获取镜像

 这里演示从[DockerHub](https://hub.docker.com/explore/)仓库获取。

```shell
docker search 关键词  #搜索镜像
docker pull [选项] [Docker Registry 地址[:端口号]/]仓库名[:标签]
#安装示例
docker pull base/archlinux    #archlinux
docker pull centos    #centos
docker pull unbuntu:17.04    #ubuntu 17.04
#推送镜像到仓库
docker push [选项] 镜像名[:标签] 用户名/镜像名
```
镜像仓库参看https://docs.docker.com/docker-cloud/builds/push-images/

注：使用空白镜像可以`docker pull scratch`

## 构建镜像

镜像是一层一层的构建的（参看下面两种构建方法），可使用`docker history 镜像名`查看其构建历史。

### docker commit构建

1. 运行容器

2. 修改容器：进行各种操作（例如增删改文件/软件包）

3. 将容器保存为新的镜像

   ```shell
   docker commit [选项] 容器名 [仓库名：标签]
   ```

   每一次commit都会构建一层镜像。**如果没有标签名，则默认为lastest**。

### dockerfile构建

1. dockerfile文件

   > Dockerfile 是一个文本文件，其内包含了一条条的指令(Instruction)，每一条指令构建一层,因此每一条指令的内容,就是描述该层应当如何构建。

   示例：

   ```shell
   FROM archlinux  #指定基础镜像 scratch是空白镜像
   MAINTAINER levinit "xx@yy.com"  #维护者
   RUN buildDeps=pacman -Syu nginx  #RUN后面是要执行的命令
   RUN echo '<h1>Hello Docker!</h1>'  >  /usr/share/nginx/html/index.html
   CMD ["nginx", "-g", "daemon off;"]
   EXPOSE 80
   ```

   Dockerfile 中每一个指令都会建立一层，因此有必要尽可能减少命令条数，例如使用`&&`将几条`RUN`指令合成一条。

   常用指令：

   - `MAINTAINER 作者` 镜像作者
   - `COPY 来源 目的`  复制
   - `ADD 来源 目地`  类似COPY，如果要复制的文件是归档文件（tar、zip、xz等），其会被自动解压
   - `ENV 环境变量`  设置环境变量供后面的指令使用
   - `EXPOSE 端口`  指定容器中的进程会监听某个端口
   - `VOLUME `  将文件或目录声明为 volume
   - WORKIDR  为后面的RUN, CMD, ENTRYPOINT, ADD或COPY指令当前工作目录
   - `RUN 指令`  在容器中运行指定的命令
   - `CMD 指令`  容器启动时运行指定的命令
   - `ENTRYPOINT 指令`  容器启动时运行的命令，不同于CMD，ENTRYPOINT**一定会被执行**，即使运行 docker run 时指定了其他命令。
   - `USER 用户名`  指定后面指令的运行用户
   - `HEALTHCHECK`  健康检查
   - `ONBUILD`

2. 构建

   ```shell
   docker build -t 镜像名[:标签] 生成路径
   #docker build -t 'centos-with-nginx:v1' ./
   docker tag 源镜像[:标签] 新镜像名[:标签]  #修改标签
   ```

   在镜像名后面加上`:`，在`:`后面添加标签，**如果没有标签名，则默认为lastest**。

# 容器操作

以下示例代码中的`<container>`表示某个容器，可以使用容器的ID或容器的名字。

## 查看状态

```shell
#查询容器 不使用-a则只查看正在运行的容器
docker ps -a
#容器详情
docker inspect <container>
#容器日志
docker logs <container>
```

## 创建、修改和删除

```shell
#创建容器
docker create -it base/archlinux

# docker run -it --rm --name 容器名 --hostname 主机名 -v 宿主机目录:容器目录:读写权限 -p 容器端口:宿主机器端口 --network 网络 base/archlinux 要执行的命令

# 以centos 镜像为基础创建一个名为webserver的容器
# 主机名webserver 以只读权限挂载宿主机的/home/data到容器的/srv/web 使用主机网络 创建成功后立即进入bash shell
docker run -it --name webserver --hostname webserver -v /home/data:/srv/web:ro --network host centos /bin/bash

#重命名
docker rename 原名 新名

#删除一个容器
docker rm 容器名或容器ID
#删除所有容器
docker rm `docker ps -a -q`
#删除所有处于退出状态的容器
docker rm -v $(docker ps -aq -f status=exited)
```

### 创建

`docker create`或`docker run`：create是创建一个容器，run是创建一个容器（并启动）执行指定命令。二者大部分参数一致，常用参数：

- `-i`交互式操作
- `-t`打开终端


- `--name 容器名` 参数给容器命名

- `-d`以守护进程运行 （run的参数）

- `-p 宿主机端口:容器端口`  映射容器某个端口到宿主机某个端口

- `-h 主机名`或`--hostname 主机名 `设置主机名

- `--ip 地址` 指定IP地址

- `--network 网络类型`  指定[网络](#网络)类型

- `-v 宿主机目录:容器目录`  挂载宿主机的卷到容器中（使用绝对路径）

  还可以在容器目录后加上`:`然后指定访问权限

  - `r`读
  - `w`写
  - `o`配合读写一起使用——如`ro`只读

- 内存限额

  - `-m 内存大小`（或`--memory`）内存限额

  - `--memory-swap=内存大小`  内存+交换分区限额

    提示：指定了 `-m` 而不指定 `--memory-swap`，那么 `--memory-swap` 默认为 `-m` 的两倍。

  - `--vm 线程数`  启用指定个数的内存工作线程

  - `--vm-bytes 给定内存大小`  每个线程分配的内存大小

- cpu限额：`-c 权重值`（或`--cpu-share`）容器使用cpu的**权重**（**CPU 的优先级**） 默认1024

- IO限额

  默认情况下，所有容器能平等地读写硬盘

  - 设置权重：` --blkio-weight 权重值`  容器读写的权重值 默认500

  - 设置bps或iops

    bps： byte per second，每秒读写的数据量。
    iops ：io per second，每秒 IO 的次数。

    - `--device-read-bps`和`--device-write-bps`
    - `--device-read-iops`和`--device-write-iops`

    使用示例：

    ```shell
    docker run -it --device-write-bps /dev/sda:30MB centos  #限制sda写入速度30MB每秒
    ```

- `/bin/bash`指定使用bash

- `--rm`使用后删除容器

### 修改和删除

- 修改容器名 `dockerename <name> <new-name>`
- 删除容器 `docker rm <container>`

## 运行容器中的命令

exec 不进入容器终端而运行容器中的命令。

`docker exec [option] <docker-name> <command>`

## 启动、进入、重启和停止

对已经创建的容器执行启动、进入、重启和停止等操作

```shell
#docker [参数] 操作容器的命令  容器名或容器id
#启动一个容器
docker start <container>
#进入已经运行的容器
docker attach <container>
#或者使用exec进入
docker exec -it <container> bash
#启动一个容器并直接进入
docker start -a <container>

#在容器中执行某条命令
docker exec <container> <command>
docker run <container> <command>
```

### 启动、进入和退出容器终端

- start 启用容器（默认以后台方式运行）

  - `-a`  或 `--attach`  启动并进入容器终端  相当于组合执行start和attach

- 进入到已经启用的容器的终端可以使用attach或exec

  - attach直接进入容器的**默认终端**，不会启动新的进程。**退出容器时，容器会停止。**

  - exec使用交互参数启动指定的容器中的终端，退出容器时，容器仍在运行。

    使用exec时进入docker终端需要使用-it参数开启交互式shell程序，并指定要使用的终端程序（如`/bin/bash`）：

    - `-i`  交互式操作  `-t`启用tty
    - `-u`指定用户 `-w`指定工作目录

- 退出容器终端

  - 可通过 Ctrl+p 然后 Ctrl+q 组合键
  - `exit`
  - `ctrl-c`

### 重启、暂停、终止

- 重启 restart
- 暂停和恢复
  - pause和unpause  暂停和从暂停中恢复
- 终止
  - stop 停用容器
  - kill  发送 SIGKILL 快速停止容器

# 网络

docker的网络有默认和自定义两种，可在创建/启动容器时指定以下的网络。

## 默认网络

docker默认创建三种网络类型：bridge、host和none。创建容器时可以使用`--network`参数指定网络类型。

可使用`docker network ls`查看：

### bridge

桥接网络，默认网络类型，默认使用docker安装时创建的桥接网络（可使用可以创建查看其配置）。每次docker容器重启时，会按照顺序从网桥配置的子网段中获取IP地址（默认网桥的网段为`172.17.0.0/16`）。

### none

无指定网络，不会分配局域网的IP。

### host

主机网络，容器的网络附属在主机上，配置相同，两者可以互通。 这种情况下不需要使用ip参数，指定port映射等。

例如，在容器中运行一个Web服务，监听80端口，则主机的80端口就会自动映射到容器中。

需要注意容器与宿主机可能发生的端口冲突。

## 用户自定义网络

用户自定义网络user-defined，有三种驱动类型：bridge、overlay和macvlan。

- 创建  `docker network create --driver <类型> <网络名>`

  ```shell
  docker network create --driver bridge br0 --subnet 172.16.0.0/16 --gateway 172.16.0.251
  ```

  -  `--subnet 网段`  指定网段

  -  `--gateway 网关地址`  指定网关

- 查看  `docker network inspect <网络名>`

# 存储

## 复制

```shell
docker cp <宿主机文件路径> <容器名>:<容器内目标路径>
```