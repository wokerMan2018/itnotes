qemu-kvm安装配置。本文内容基于——主机**ArchLinux**，虚拟机**centos 7.x**，其他发行版**或有出入** 。

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

## qemu管理虚拟机

参看[archlinux-wiki:qemu](https://wiki.archlinux.org/index.php/QEMU#Creating_new_virtualized_system)和shell脚本[qemu-vm-install.sh](qemu-vm-install.sh)

示例在x86_64宿主机上以iso文件引导安装系统：

- x86_64

  示例安装archlinux_x86-64：

  ```shell
  #创建虚拟机的虚拟盘 格式为qcow2 名字为vm-arch 大小8g
  #不指定-f 类型默认使用raw格式
  qemu-img create -f qcow2 vm-arch 8g
  
  #创建一个虚拟机 内存2g cpu 4个 挂载一个iso文件和一个虚拟盘
  #内存和cpu是可选的，但是一般建议设置内存值，避免默认分配的内存过小
  qemu-system-x86_64 -m 2g -smp 4 -cdrom arch.iso vm-arch #-nograhic  #nographic用以纯字符界面启动
  
  #启动系统（可从任意安装系统的虚拟盘文件中进行引导，内存和cpu数量可根据使用需求情况定义）
  qemu-system-x86_64 -m 2g -smp 4 vm-arch
  ```

- 安装arm/aarch64虚拟机

  以aarch64为例，安装某些系统（例如centos7+）需要一个额外的uefi固件（AVMF, aarch vitual machine fireware) QEMU_EFI.fd用以引导。

  QEMU_EFI.fd文件下载：

  - https://github.com/tianocore/edk2

  - https://github.com/hoobaa/qemu-aarc64/raw/master/QEMU_EFI.fd
  - https://pkgs.org/download/edk2-aarch
  - 一些发行版中使用包管理器搜索avmf edk2+aarch等关键字，安装软件包后，其文件目录中有该文件。

  示例安装centos_aarch64：

  ```shell
  #创建虚拟机的虚拟盘 格式为qcow2 名字为vm-arch 大小8g
  qemu-img create vm-aarch-cent 8g
  
  #创建一个虚拟机 内存2g cpu 4个 挂载一个iso文件和一个虚拟盘
   qemu-system-aarch -m 2g -cpu cortex-a57 -M virt -bios QEMU_EFI.fd -nograhic vm-aarch-cent -cdrom centos.iso
   
  #启动系统（可从任意安装系统的虚拟盘文件中进行引导，内存和cpu数量可根据使用需求情况定义）
  qemu-system-aarch -m 2g -cpu cortex-a57 -M virt -bios QEMU_EFI.fd -nograhic vm-aarch-cent
  ```

  aarch64虚拟机启动必须指定这些选项：

  - 虚拟机类型 `-M`或`-machine type=`，一般值就是`virt`
  - UEFI引导固件`-bios` ，值即上文提到的avmf引导固件 QEMU_EFI.fd
  - cpu类型`-cpu`，可以通过`qemu-system-aarch64 -machine virt help`查看所有支持的类型值

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

- aarch/arm虚拟机安装时提示`acpi requires uefi`

  需要额外的uefi固件，适用与x86的包名一般是ovmf，aarch/arm的为avmf，其由[edk2](https://github.com/tianocore/edk2)提供，包名多含有`edk2`字样，可使用包管理器搜索。

  例如：https://pkgs.org/download/edk2中aarch相关包

  可能还需要配置`/etc/libvirt/qemu.conf`中nvram的值如下：

  ```shell
  nvram = [
     "/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd",
    "/usr/share/OVMF/OVMF_CODE.secboot.fd:/usr/share/OVMF/OVMF_VARS.fd",
    "/usr/share/AAVMF/AAVMF_CODE.fd:/usr/share/AAVMF/AAVMF_VARS.fd",
    "/usr/share/AAVMF/AAVMF32_CODE.fd:/usr/share/AAVMF/AAVMF32_VARS.fd"
  ]
  ```

  其中最后两行AVVMF是用于aarch/arm的。

  参看[arch-wiki:libvirtd](https://wiki.archlinux.org/index.php/Libvirt_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#UEFI_%E6%94%AF%E6%8C%81)一文中UEFI 支持一节。

  提示：安装固件或修改配置后重启libvirtd服务再进行尝试。

- Failed to initialize a valid firewall backend

  安装`ebtables`和`dnsmasq`并启用服务，重启`libvirtd`服务。

- Error starting domain: internal error Network 'default' is not active.

  ```shell
  sudo virsh net-start default
  sudo virsh net-autostart default
  ```

- 启动域错误internal error: process exited while connecting to monitor: ioctl(KVM_CREATE_VM) failed: 16 Device or resource busy

  启动了其他虚拟机工具（例如virtualbox），关闭其他虚拟工具即可。