qemu-kvm安装配置。本文内容基于——主机**ArchLinux**，虚拟机**centos 7.x**，其他发行版**或有出入** 。

[TOC]

# 硬件支持

现在的硬件一般都支持虚拟化。可执行以下命令查询：

```shell
 lscpu |grep -E "(vmx|svm)"
 #或
  grep -E "(vmx|svm)" --color=always /proc/cpuinfo
```

如果有输出信息就表示支持虚拟化。

注意：确保在BIOS中开启了虚拟化支持（virtualization support），一般的该选项默认开启。

# 内核模块

需要加载kvm相关内核模块kvm、kvm_intel(或kvm_amd)和virtio，查看是否已经启用这些模块：

```shell
lsmod | grep kvm    #出现kvm kvm_intel(或kvm_amd)
lsmod | grep virtio  #出现 virtio
```

如果没有加载，对其加载

```shell
modprobe virtio kvm kvm_intel
```

# 基本安装和配置

## 相关工具

- `qemu`虚拟操作系统仿真器  

  图形界面qemu `virt-manager `  可选

- `libvirt` 管理虚拟机和其它虚拟化功能（适用于多种虚拟机工具）

  ```shell
  systemctl start libvirtd
  ```


- 图形查看`virt-viewer`

- 虚拟机网络连接相关

  - NAT/DHCP（默认的网络连接方式）：`ebtables`和`dnsmasq`

    未安装和配置这些工具而使用了NAT/DHCP时会报错：`libvirt: “Failed to initialize a valid firewall backend”` ，需在安装这些工具后启用之：

    ```shell
    systemctl start ebtables dnsmasq
    #可能还需要重启libvirtd
    systemctl start libvirtd
    ```

  - 网桥模式：`bridge-utils`

  - ssh连接：`openbsd-netcat`


## Failed to initialize a valid firewall backend

参看前文[虚拟工具-虚拟机网络连接相关](#虚拟工具)

## Error starting domain: internal error Network 'default' is not active.

```shell
sudo virsh net-start default
sudo virsh net-autostart default
```

## 启动域错误internal error: process exited while connecting to monitor: ioctl(KVM_CREATE_VM) failed: 16 Device or resource busy

启动了其他虚拟机工具（例如virtualbox），关闭其他虚拟工具即可。