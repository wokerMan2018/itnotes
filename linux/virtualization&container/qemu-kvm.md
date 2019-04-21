[TOC]

# 简介

## KVM、QEMU和libvirt

- KVM （Kernel Virtual Machine）：集成到Linux**内核**的Hypervisor（虚拟机监控器）**模块**。
- QEMU（quick emulator）：一个**独立的虚拟化解决方案**，并不依赖KVM。

KVM+QEMU虚拟化解决方案：用户借助用户空间的**管理工具**QEMU与内核模块交互，QEMU使用KVM实现内核中模块对**处理器虚拟化**特性的支持以提升性能。

- libvirt：一组软件的汇集（包括 C 语言 API、守护进程libvirtd和工具virsh），提供了**便捷管理虚拟机和其它虚拟化功能**。其目标是提供一个单一途径以管理多种不同虚拟化方案以及虚拟化主机（如kvm/qemu、xen、lxc等等）

## KVM支持

### CPU虚拟化功能

KVM需要虚拟机宿主（host）的处理器带有虚拟化支持（Intel处理器VT-x，AMD处理器AMD-V）

```shell
 lscpu |grep -E "(vmx|svm)"
 #或
  grep -E "(vmx|svm)" --color=always /proc/cpuinfo
```

如果有输出信息就表示支持虚拟化。

注意：确保在BIOS中开启了虚拟化支持（virtualization support）。

### linux内核kvm模块

检查看是否已经启用kvm相关模块：

```shell
lsmod | grep kvm    #出现kvm kvm_intel(或kvm_amd)
lsmod | grep virtio  #出现 virtio
```

如果没有加载以上模块可使用以下命令临时加载：

```shell
modprobe virtio kvm kvm_intel
```

总是加载：

```shell
echo "options kvm_intel nested=1" > /etc/modprobe.d/kvm.conf
```

# QEMU+KVM方案

## 环境配置

确保cpu支持虚拟化以及linux内核kvm模块已经加载，安装以下工具并启动相关服务：

- `qemu`

- `libvir`

  ```shell
  systemctl start libvirtd  #使用前需要启用该服务
  ```


- 网络连接相关

  - NAT/DHCP（默认的网络连接方式）：`ebtables`和`dnsmasq`

    ```shell
    systemctl start ebtables dnsmasq  #启用相关服务
    ```

  - 网桥模式：`bridge-utils`

  - ssh连接：`openbsd-netcat`

## 虚拟机工具

### virt命令行工具

libvirt集成了一些命令行工具如`virt-install`、`virsh`和`virt-clone`等。

- virt-install

  ```shell
  virt-install -n <vm-name> -r <vm-memory-size> --disk path=</path/to/vm-disk-path>,size=16\
  -l <os-file> -x ks=<kickstart-file.cfg>
  ```

  主要参数：

  - `-n` 虚拟机名字
  - `--vcpus`  虚拟机cpu数量
  - `-r`

- virsh

- virt-clone

### qemu图形界面工具

一些图形界面工具代替命令行操作，如：

- `virt-manager `  
- `gnome-boxes`

# 问题解决

- Failed to initialize a valid firewall backend

  安装`ebtables`和`dnsmasq`并启用服务，重启`libvirtd`服务。

- Error starting domain: internal error Network 'default' is not active.

  ```shell
  sudo virsh net-start default
  sudo virsh net-autostart default
  ```

- 启动域错误internal error: process exited while connecting to monitor: ioctl(KVM_CREATE_VM) failed: 16 Device or resource busy

  启动了其他虚拟机工具（例如virtualbox），关闭其他虚拟工具即可。