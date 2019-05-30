[TOC]

# 准备工作

- 划分磁盘空间用于linux安装（推荐至少30G）

- **确定系统引导方式**以确认[启动盘制作](#启动盘制作)方法（[UEFI](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)还是Legacy BIOS，可在设备的BIOS中查看和设置。）

- **在bios设置中关闭启设置中的安全启动**

  *如有没有该设置则略过，对Arch Linux使用安全启动可参考[archwiki-Secure Boot](https://wiki.archlinux.org/index.php/Secure_Boot_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。*

- **互联网**（安装需要联网）

- U盘（本文讲述使用U盘作为启动介质安装操作系统）

- [Arch Linux 系统镜像](https://www.archlinux.org/download/)

- nano或vi/vim基本操作技能

  *编辑配置文件时需要用到的最基本的编辑操作。*

## U盘启动盘制作

根据情况选择：

- 如果设备支持[UEFI](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))启动，**可以**直接将下载的系统镜像文件解压或挂载，复制其中的内容到U盘根目录即可。

- 使用工具制作启动盘

  - windows下可使用[usbwriter](https://sourceforge.net/projects/usbwriter/)、[poweriso](http://www.poweriso.com)、[winsetupfromusb](http://www.winsetupfromusb.com/)等工具。

  - Linux/OSX下可使用dd命令。示例：

    ```shell
    #/path/arch.iso是下载的Arch Linux镜像文件路径  /dev/sdx U盘的设备编号（根据情况修改如sdb sdc）
    dd if=/path/arch.iso of=/dev/sdx bs=4096
    ```


## 启动引导

1. 在计算机上插入U盘，然后开启（重启）计算机。
2. 适时选择启动方式——使用USB启动（不同设备方法设置不同）。
3. 载入U盘上的系统 > 回车选择**第一项**（默认）> 等待一切载入完毕……

# 基础安装

以下安装过程中遇到需要选择（y/n）的地方，如不清楚如何选择，可直接回车或按下<kbd>y</kbd>即可。

## 系统分区

### 规划

在进行分区操作前或许要了解以下信息以进行预规划。

- 硬盘情况

  分区类型、快设备、扇区大小等等信息。如果对设备硬盘分区情况不了解，可使用如下命令查看：

  ```shell
  lsblk  #列出所有可用块设备的信息
  fdisk -l  #查看硬盘信息
  fdisk -l |grep gpt  #查看硬盘是否使用GPT
  parted -l   #查看硬盘信息
  ```

- 分区工具使用，例如parted、fdisk、cfdisk

  这里简要介绍fdisk工具，上手容易。

  - 查看整个磁盘的情况 `cfdisk /dev/sda` （第二块硬盘则是`cfdisk /dev/sdb` ）
  - 利用箭头进行上下左右移动，选中项会高亮显示，回车键确定操作。
  - `New`用于新建分区，输入新建分区的大小并回车，建立了一个分区。
  - `Delete`删除当前选中的分区。
  - `Type`选择分区类型。
  - `Write`用于保存操作。
  - `quit`退出（直接输入`q`亦可）。

- [分区表](https://zh.wikipedia.org/wiki/%E5%88%86%E5%8C%BA%E8%A1%A8)

  如果硬盘未进行划分，执行`cfdisk`会提示选择分区方式，**如果设备支持[GPT](https://wiki.archlinux.org/index.php/Partitioning_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E9.80.89.E6.8B.A9GPT_.E8.BF.98.E6.98.AF_MBR)则建议使用GPT** 。

  如果已经是mbr分区表，而希望采用gpt分区表，可使用parted重建：

  ```shell
  parted /dev/sda  #进入parted命令行
  mklable  #建立分区表，系统会询问采用什么格式
  gpt  #输入gpt回车即可
  ```

- 分区参考

  - UEFI

    - ESP（即[EFI system partition](https://wiki.archlinux.org/index.php/EFI_system_partition_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))）  存放UEFI启动引导文件 （建议200M+）

    - /boot  启动分区（根据下面描述的情况确定是否需要单独划分）

      可以单独创建（至少约100M），也可以将esp挂载到`/boot`，从而无需创建`/boot`（个人使用该方法，因此ESP一般分配200M+）。

      但对于已经存在一个windows且打算保留的情况时，由于windows安装时自动划分的ESP仅100M，将其再直接挂载到`/boot`使用则空间，这种情况还是创建一个`/boot分区`，或者想办法对ESP扩容使用。

    - /  系统根目录

      根据情况划分，需要安装的应用越大/越多，规划空间就越多，一般桌面用户建议至少25G+。

    - home  用户目录（建议单独划分）

      **如果作为日常使用需要存放文件，当然越大越好。**
  
  - MBR（分区大小建议同上）
  
    - /boot  启动分区  200M+
  - /  系统根目录
    - home（建议单独划分）
  
  关于SWAP的建议：推荐使用[swap文件](https://wiki.archlinux.org/index.php/Swap_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#%E4%BA%A4%E6%8D%A2%E6%96%87%E4%BB%B6)（brtfs分区除外，因为其不支持swap文件，注意该提示可能会过时）而不是使用单独的swap分区，使用swap文件比使用swap分区更为灵活，易于调整。
  
  二者没有性能差别。物理内存很大也可以不划分swap，**需要进行大量使用内存的操作而可能造成内存耗尽建议划分，要使用休眠功能必须划分。**休眠所需swap大小和休眠前系统开启的程序占用的内存大小有关，根据情况酌情调整。
  
  分区大小建议：不清楚自己需要划分多大的分区，尤其是根分区`/`和swap分区（还是推荐使用swap文件），建议使用LVM，使用LVM创建vg（卷组），在vg中创建lv（逻辑卷），使用这些逻辑卷创建除了ESP之外的分区。

### UEFI模式

检查当前是否使用UEFI启动：

```shell
ls /sys/firmware/efi/  #如果该文件存在则表示使用UEFI启动
```

- ESP(EFI系统分区)

  - 已经存在ESP

    支持UEFI的设备上，先前已经存在一个操作系统（例如windows10）且**打算保留原操作系统，不要对EFI系统分区进行任何操作。**

    ```shell
    fdisk -l |grep -i efi  #查看是否存在efi
    ```

    如果不保留原来的EFI系统分区中的引导文件，直接对其格式化即可：

    ```shell
    mkfs.vfat /dev/sda1  #这里假设EFI系统分区位于/dev/sda1（下同）
    ```

  - 新建ESP

    使用cfdisk或其他工具创建一个100M（可以稍微大一些），Type选择类型为`EFI system`即可。

    *这里假设EFI系统分区位于/dev/sda1*，下同。

- 其他分区

  - 使用[LVM](https://wiki.archlinux.org/index.php/LVM_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))创建其他分区

    使用cfdisk或其他磁盘工具将剩余空间创建一个分区。*假设其为/dev/sda2。*

    ```shell
    #1.建立物理卷：在 /dev/sda2建立物理卷
    pvcreate /dev/sda3
    
    #2.建立卷组：新建名为linux的卷组 并 将sda2加入到卷组中
    vgcreate linux /dev/sda2
    
    #3.建立逻辑卷：在linux卷组中建立root和home逻辑卷
    #lvcreate -L 200M linux -n boot   #如果要创建boot分区
    lvcreate -L 30G linux -n root  #3.2.1  用linux卷组中30G空间建立适用于根分区的逻辑卷
    lvcreate -l +100%FREE linux -n home   #3.2.2  用linux卷组中所有剩余空间建立home逻辑卷
    #lvcreate -L 100G linux -n home  #创建home逻辑卷并指定100GB空间
    
    #4.各个逻辑卷创建文件系统
    mkfs.ext4 /dev/mapper/linux-root    #根分区
    mkfs.ext4 /dev/mapper/linux-home   #home分区
    #mkfs.ext4 /dev/mapper/linux-boot   #如果创建有boot分区
    
    #5.挂载
    mount /dev/mapper/linux-root /mnt    #挂载根分区
    
    mkdir /mnt/home    #建立home挂载点
    mount /dev/mapper/linux-home /mnt/home
    
    #将/boot作为esp的挂载点
  #这样除了efi文件外，grub、kernel等也会安装到esp上
    mkdir -p /mnt/boot
  mount /dev/sda1 /mnt/boot
    #如果创建有boot分区，或不将/boot作为esp挂载点，而是将esp挂载的/boot/efi
    #mkdir /mnt/boot/efi -p
    #mount /dev/sda1 /mnt/boot/efi
    ```
  
    swap文件（可选）
  
    ```shell
  swap_size=8G  #swap文件大小(根据具体情况设置大小)
    swap_file=/mnt/home/swap  #swap文件存放位置
  fallocate -l $swap_size $swap_file
    chmod 600 $swap_file
  mkswap $swap_file
    swapon $swap_file
    ```
  
  - 使用标准方式创建其他分区
  
    使用cfdisk或其他工具创建`/`根分区（*假设为/dev/sda2*）和home（*假设为/dev/sda3*）用户家目录分区，创建文件系统：
  
    ```shell
    #1. 挂载根分区
    mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt    #挂载根分区
    
    #2. 挂载home分区
    mkfs.ext4 /dev/sda3
  mkdir /mnt/home    #建立home挂载点
    mount /dev/sda3 /mnt/home    #挂载home逻辑卷到/home
    
    #3.挂载esp
    mkdir -p /mnt/boot/efi  #建立efi系统分区的挂载点
    mount /dev/sda1 /mnt/boot/efi    #挂载esp到/boot/efi
    ```
  
    swap文件同上。

### Legacy模式

无ESP相关部分，使用cfdisk等工具创建一个单独的200M分区作为boot，其余分区可以使用lvm或标准方式创建，参看上文，但是略去esp相关部分，只需要挂载boot分区（例如其为`/dev/sda1`）到`/mnt/boot`：

```shell
#...创建了挂载的/mnt的根分区
#...挂载home
#挂载boot
mkdir /mnt/boot
mkfs.vfat /dev/sda1
mount /dev/sda1 /boot
```

swap文件同上。

## 连接网络

```shell
dhcpcd    #连接到有线网络
wifi-menu    #连接到无线网络 执行后会扫描网络 选择网络并连接 按提示输入密码
ping -c 5 z.cn  #测试连接情况
ip a  #查看分配的ip
```

## 配置镜像源

在安装前最好选择较快的镜像，以加快下载速度。
编辑` /etc/pacman.d/mirrorlist`，选择首选源（按所处国家地区关键字索搜选择，如搜索china），将其添加到文件顶部，保存并退出。一些中国地区镜像源如：

```shell
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.163.com/archlinux/$repo/os/$arch
```

## 安装基础系统

```shell
pacstrap -i /mnt base base-devel
```
## 建立fstab文件

```shell
genfstab -U /mnt > /mnt/etc/fstab
#swap file
echo '/home/swap none swap defaults 0 0'  >> /mnt/etc/fstab
cat /mnt/etc/fstab    # 查看生成的 /mnt/etc/fstab
```
## 进入系统

```shell
arch-chroot /mnt
```

## 激活lvm2钩子

**使用了lvm分区方式，需要执行该步骤**，否则跳过。

编辑/etc/mkinitcpio.conf文件，找到类似字样：

>HOOKS="base udev autodetect modconf block  filesystems keyboard fsck"

在block 和 filesystems之间添加`lvm2`（注意lvm2和block及filesystems之间有一个空格），类似：

> HOOKS="base udev autodetect modconf block lvm2 filesystems keyboard fsck"

再执行：
```shell
mkinitcpio -p linux
```

## 用户管理

- 设置root密码和建立普通用户

  ```shell
  passwd     #设置或更改root用户密码  接着输入两次密码（密码不会显示出来）
  useradd user1    #添加名为user1的普通用户
  passwd user1    #设置或更改user1用户密码 接着输入两次密码
  ```


- 给予普通用户sudo权限

  ```shell
  echo  'user1 ALL=(ALL) ALL' > /etc/sudoers.d/sudo    #将user1加入sudo
  ```
  
  或使用visudo编辑添加：
  
  ```shell
  pacman -S vim  #visudo默认编辑器是vim
  visudo  #该命令会打开一个文件
  #在该文件中添加 user1 ALL=(ALL) ALL'
  ```


## 时钟

保留windows的用户可能还需要**参考后文[windows和linux统一使用UTC](#windows和linux统一使用UTC)** 。

linux时钟分为系统时钟（system clock）和硬件时钟（Real Time Clock, RTC——即实时时钟，电脑主板记录的时钟）。

设置时区，将系统时间和硬件时间统一：

```shell
date #查看当前系统时间
#设置时区 示例为中国东八区标准时间--Asia/Shanghai  |也可使用tzselect命令按提示选择时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock -w -u    #将当前系统时间写入到硬件时钟  并使用utc时间（推荐）
# hwclock -s -u  #将当前硬件时间写入到系统时钟  并使用utc时间
```

## 主机名

```shell
echo MyPC > /etc/hostname  #MyPC是要设置的主机名
```

**注意:** 在 Arch Linux chroot 安装环境中，*hostnamectl*不起作用，因此不能使用`hostnamectl set-hostname 主机名`设置主机名。

## 网络配置

linux自带的`linux-frimware`已经支持大多数驱动，如果某些设置不能使用，参看[archwiki:网络驱动](https://wiki.archlinux.org/index.php/Wireless_network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.AE.89.E8.A3.85_driver.2Ffirmware)。

如果要安装Gnome、KDE等桌面环境，可以略过该步骤，桌面环境将集成图形界面网络管理工具。

- 有线网络

  ```shell
  systemctl enable dhcpcd  #开机自启动有线网络 当然也可以手动执行 dhcpcd 连接
  ```

- 无线网络

  ```shell
  pacman -S iw wpa_supplicant dialog    #无线网络需要安装这些工具使用wifi-menu联网
  ip a  #查看到当前连接无线的网卡名字
  systemctl enable netctl-auto@网卡名字  #开机自动使用该网卡连接曾经接入的无线网络
  ```

  参看archlinux-wiki的[netctl](#https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和[网络配置](https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))了解更多。

## 系统引导

- 安装[微码](https://wiki.archlinux.org/index.php/Microcode_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))（建议安装）

  ```shell
  pacman -S intel-ucode   #仅intel CPU安装
  pacman -S amd-ucode  #仅amd CPU安装
  ```

- 如过要引导多系统安装（可选）

  ```shell
  pacman -S os-prober
  ```

- 引导工具

  ```shell
  pacman -S grub
  ```

  - 使用UEFI

    ```shell
    pacman -S efibootmgr  #使用esp还需安装
    grub-install --efi-directory=/boot --bootloader-id=grub
    ```

   - 使用Legacy

     ```shell
     grub-install  /dev/sda
     ```


- 生成引导

   ```shell
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

   如果在生成引导命令执行后卡住，很久不能成功，参看下方[生成grub配置时挂起](#生成grub配置时挂起)解决。

**注意**：os-prober可能需要在系统安装完毕后，**重启**进入系统**再次执行**引导**生成配置**命令就能检测到其他系统。

至此**基础系统**安装完成，可以**连续按两次`ctrl`+`d` ，输入`reboot`重启并拔出u盘**。

**基础系统仅有字符界面**，当然也可以继续进行下面的[常用配置](#常用配置)安装流程。

如果windows+archlinux双系统用户在重启后直接进入了Windows系统，可参看[选择grub为第一启动项](#选择grub为第一启动项) 解决。

# 常用配置

## 图形界面

### 显卡驱动

首先需要了解设备的显卡信息，也可是使用`lspci | grep VGA`查看。根据显卡情况安装驱动：

```shell
pacman -S xf86-video-vesa     #通用显卡
pacman -S xf86-video-intel     #intel核心显卡  可不安装 内核中已经集成开源实现
pacman -S nvidia                       #nvidia显卡驱动（包含vulkan）
pacman -S mesa                       #amd显卡使用开源mesa驱动即可(一般已经在基础系统中集成)

#vulkan 支持
pacman -S vulkan-intel    #intel显卡
pacman -S vulkan-radeon    #amd/ati显卡

#opencl支持
pacman -S opencl-mesa  #mesa(amd)
pacman -S opencl-nvidia  #nvidia
```
注意：

带有独立显卡的设备不安装显卡驱动可能造成进入图形界面出错卡死，请务必先安装显卡驱动！

双显卡设备，可参看后文[双显卡管理](#双显卡管理)。

### 桌面环境/窗口管理器

安装一个[桌面环境](https://wiki.archlinux.org/index.php/Desktop_environment_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或者[窗口管理器](https://wiki.archlinux.org/index.php/Window_manager_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。

- 桌面环境，如[Plasma](https://wiki.archlinux.org/index.php/KDE_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或者[Gnome](https://wiki.archlinux.org/index.php/GNOME_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))：

  ```shell
  pacman -S plasma sddm  && systemctl enable sddm  #plasma(kde)
  pacman -S gnome gdm  && systemctl enable gdm  #gnome
  ```


- 窗口管理器，如[i3wm](https://wiki.archlinux.org/index.php/I3_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或[openbox](https://wiki.archlinux.org/index.php/Openbox_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

  ```shell
  pacman -S xorg-server xorg-xinit      #务必安装
  pacman -S i3  #i3wm
  pacman -S awesome  #awesome
  pacman -S openbox  #openbox
  ```

  窗口管理还需要自行配置[显示管理器](https://wiki.archlinux.org/index.php/Display_manager_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或[xinitrc](https://wiki.archlinux.org/index.php/Xinitrc_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))，用以启动窗口管理器 。

### 字体

参看[archwiki:fonts](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))选择安装字体。

- 终端等宽字体，如`ttf-dejavu`
- 数学和符号字体，如`ttf-symbola`（需要aur）（符号中也包含emoji表情，另外`noto-fonts-emoji` 是noto字体的emoji表情符号包）
- 中文字体参看下文[中文显示](#中文显示)。

### Locale设置

参看[Locale](https://wiki.archlinux.org/index.php/Locale_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)) 设置

编辑`/etc/locale.gen`，根据本地化需求移除对应行前面的注释符号。

以中文用户常用locale为例，去掉这些行之前前面#号：

```shell
en_US.UTF-8 UTF-8
zh_CN.GBK
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
```

保存退出后执行：

```shell
locale-gen
```

### 中文显示和输入

中文字体选择一款（或多款）安装，如：

```shell
pacman -S wqy-micorhei    #文泉驿微米黑
pacman -S adobe-source-han-sans-cn-fonts    # 思源黑体简体中文包
pacman -S ttf-arphic-uming    #文鼎明体
```

更多字体参看[中日韩越字体](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E4.B8.AD.E6.97.A5.E9.9F.A9.E8.B6.8A.E6.96.87.E5.AD.97) 。安装思源黑体全集（或noto fonts cjk）而出现的中文显示异体字形的问题，参看该文的[修正简体中文显示为异体（日文）字形](https://wiki.archlinux.org/index.php/Arch_Linux_Localization_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E4.B8.AD.E6.96.87.E5.AD.97.E4.BD.93) 。



输入法可选择[fcitx](https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或[ibus](https://wiki.archlinux.org/index.php/IBus_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。

- fcitx本体带有：拼音（主流双拼支持）、二笔、五笔（支持五笔拼音混输）等：

  ```shell
  pacman -S fcitx-im fcitx-configtool     #安装fcitx本体及配置工具
  #按需选择下面的输入法支持或功能插件
  pacman -S fcitx-cloudpinyin        #云拼音插件（推荐拼音用户安装）
  pacman -S fctix-rime                    #rime中州韵（即小狼毫/鼠须管）引擎 任选
  pacman -S fcitx-libpinyin           #智能拼音（支持搜狗词库）任选
  pacman -S fcitx-sogoupinyin    #可使用搜狗拼音（自带云拼音）任选
  ```

  提示：云拼音插件不支持RIME和搜狗，且其默认使用谷歌云拼音，可在fcitx设置中选用百度。

  环境变量设置——在`/etc/environment`添加：

  ```shell
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS="@im=fcitx"
  ```

  安装完毕后需要在配置工具(fictx-configtool)中添加相应的输入法才能使用。

- ibus

  ```shell
  pacman -S ibus  ibus-qt        #ibus本体 ibus-qt保证在qt环境中使用正常
  pacman -S ibus-pinyin         #拼音
  pacman -S ibus-libpinyin    #智能拼音（支持导入搜狗词库）
  pacman -S ibus-rim               #rime
  ```

  环境变量设置：在`/etc/environment`添加：

  ```shell
  export GTK_IM_MODULE=ibus
  export XMODIFIERS=@im=ibus
  export QT_IM_MODULE=ibus
  ```

  安装完毕后需要在gnome配置(gnome-control-center)的地区和语言中添加输入源，然后在ibus设置中添加输入法才能使用。

## 声音

**桌面环境用户可略过**。

窗口管理器用户可以安装`alsa-utils`管理声音，安装该包后笔记本可以使用相应的快捷键进行控制。更多信息查看[ALSA安装设置](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
pacman -S alsa-utils
alsamixer    #安装上一个包后可使用该命令控制声音设备
```

如果设备[没有声音](#没有声音)，可以使用`alsamixer`解除静音。

## 软件包管理器

### pacman

更多信息查看[archwiki:pacman]((https://wiki.archlinux.org/index.php/Pacman_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。

- 常用命令

  ```shell
  pacman -Syu   #升级整个系统
  pacman -S <package-name>   #安装软件 ,package-name>即软件名
  pacman -Sw <package-name>   #只下载不安装（安装包存放在/var/cache/pacman/pkg/
  pacman -R <package-name>   #移除某软件但不移除其依赖
  pacmna -Rcn   <package-name>   #移除某软件及相关依赖
  pacman -Qi name  #查看已经安装的某软件的信息
  pacman -Ss <word>  #从软件源查询有某关键字的软件 <word>即是要查询的关键字
  pacman -Qs word  #在已安装软件中根据关键字搜寻
  pacman -Qdt  #查看和卸载不被依赖的包
  pacman -Fs <command>  #查看某个命令属于哪个软件包
  ```

- pacman 设置（可选）
  配置文件在`/etc/pacman.conf`，编辑该文件：

  - 彩色输出：取消`#Color`中的#号。

  - 升级前对比版本：取消`#VerbosePkgLists`中的#号。

  - 社区镜像源：在末尾添加相应的源，[中国地区社区源archlinuxcn](https://github.com/archlinuxcn/mirrorlist-repo)

    例如添加archlinuxcn.org的源：

    ```shell
    [archlinuxcn]
    SigLevel = Optional TrustedOnly
    Server = http://repo.archlinuxcn.org/$arch
    ```

    添加完后执行：

    ```shell
    pacman -Syu archlinuxcn-keyring
    ```

此外可使用 [pacman图形化的前端工具](https://wiki.archlinux.org/index.php/Graphical_pacman_frontends_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。

### AUR

AUR(Arch User Repository）是为用户而建、由用户主导的Arch软件仓库。aur软件可以通过[aur助手工具](https://wiki.archlinux.org/index.php/AUR_helpers)器搜索、下载和安装，或者从[aur.archlinux.org](https：//aur.archlinux.org)中搜索下载，用户自己通过makepkg生成包，再由pacman安装。

## 设备连接

### 触摸板

**多数桌面环境已经集成**。

```shell
pacman -S xf86-input-synaptics
```
### 蓝牙

**多数桌面环境已经集成**。

```shell
pacman -S bluez
systemctl enable bluetooth
usermod -aG lp user1    #user1是当前用户名
```
蓝牙控制：命令行控制安装`bluez-utils`，使用参考[通过命令行工具配置蓝牙](https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E9.80.9A.E8.BF.87.E5.91.BD.E4.BB.A4.E8.A1.8C.E5.B7.A5.E5.85.B7.E9.85.8D.E7.BD.AE.E8.93.9D.E7.89.99)；[蓝牙图形界面工具]((https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.9B.BE.E5.BD.A2.E5.8C.96.E5.89.8D.E7.AB.AF))如`blueberry`。

### NTFS分区

桌面环境的文件管理器一般都能读取NTFS分区的内容，但不一定能能够写入。可使用`ntfs-3g`挂载：

```shell
pacman -S ntfs-3g       #安装
mkdir /mnt/ntfs          #在/mnt下创建一个名为ntfs挂载点
lsblk                                 #查看要挂载的ntfs分区 假如此ntfs分区为/dev/sda5
ntfs-3g /dev/sda5 /mnt/ntfs       #挂载分区到/mnt/ntfs目录
```
### U盘和MTP设备

**桌面环境一般能自动挂载**。

- 使用[udisk](https://wiki.archlinux.org/index.php/Udisks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和libmtp

  ```shell
  pacman -S udiskie udevil
  systemctl enable devmon@username.service    #username是用户名
  pacman -S libmtp
  ```

  在/media目录下即可看到挂载的移动设备。

- 使用gvfs gvfs-mtp（thunar pcmafm等文件管理器如果不能挂载mtp，也可安装`gvfs-mtp` ）

  ```shell
  pacman -S gvfs    #可自动挂载u盘
  pacman -S gvfs-mtp    #可自动挂载mtp设备
  ```

# 其他配置/常见问题

## 参考资料

- [获取和安装Arch](#https://wiki.archlinux.org/index.php/Category:Getting_and_installing_Arch_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
- [Arch相关](#https://wiki.archlinux.org/index.php/Category:About_Arch_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
- [系统维护](https://wiki.archlinux.org/index.php/System_maintenance_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
- [pacman提示和技巧](#https://wiki.archlinux.org/index.php/System_maintenance_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

## 生成grub配置时挂起

archroot中执行`grub-mkconfig`命令挂起，系统无任何反馈信息。参看[Arch GRUB asking for /run/lvm/lvmetad.socket on a non lvm disk](https://unix.stackexchange.com/questions/105389/arch-grub-asking-for-run-lvm-lvmetad-socket-on-a-non-lvm-disk)。

1. 终止`grub-mkconfig`命令，执行`exit`退出archroot；

2. 假设前面archroot的为`/mnt`，执行：

   ```shell
   mkdir /mnt/hostrun
   mount --bind /run /mnt/hostrun
   ```

3. `archroot /mnt`进入/mnt，再执行：

   ```shell
   arch-chroot /mnt /bin/bash
   mkdir /run/lvm
   mount --bind /hostrun/lvm /run/lvm
   ```

4. 重新执行`grub-mkconfig`生成grub配置。

   退出archroot前先`umount /run/lvm`。

## 笔记本电源管理

参看wiki[Laptop](#https://wiki.archlinux.org/index.php/Laptop_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和本人笔记[laptop笔记本相关](../laptop笔记本相关.md)

## 开机后直接进入windows系统

安装系统后重启，**直接进入了windows** 。

原因：windows的引导程序bootloader并不会将linux启动项加入到启动选择中，且windows的引导程序处于硬盘启动的默认项。（**在windows上进行重大更新后也可能出现该情况**）

解决：进入BIOS，找到启动设置，**将硬盘启动的默认启动项改为grub**，保存后重启。

## 无法启动图形界面

参看前文[图形界面](#图形界面) 。原因可能是：

- 没有安装显卡驱动（双显卡用户需安装两个驱动）
- 没有正确安装图形界面
- 没有自启动图形管理器或xinintrc书写错误

## 非root用户（普通用户）无法启动startx

重装一次`xorg-server`

## 无法挂载硬盘（不能进入Linux）

原因：**windows开启了快速启动可能导致linux下无法挂载**，提示如：

>The disk contains an unclean file system (0, 0).
>Metadata kept in Windows cache, refused to mount.

等内容。

解决：在windows里面的 电源选项管理 > 系统设置 > 当电源键按下时做什么， 去掉勾选启用快速启动。或者直接在cmd中运行：`powercfg /h off`。

## 高分辨率（HIDPI）屏幕字体过小

桌面环境设置中可调整。参考[archwiki-hidpi](https://wiki.archlinux.org/index.php/HiDPI)

## 蜂鸣声（beep/错误提示音）
去除按键错误时、按下tab扩展时、锁屏/注销等出现的“哔～”警告声。参考[archwiki-speaker](https://wiki.archlinux.org/index.php/PC_speaker)
```shell
rmmod pcspkr    #暂时关闭
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf   #直接屏蔽
```
## 没有声音

一般出现在轻量桌面(如xfce)或窗口管理器上，因为archlinux安装后默认处于静音状态。

安装`alsa-utils`，然后执行`alsamixer`进入 其ncurses 界面：

使用<kbd>←</kbd>和<kbd>→</kbd>方向键移动，选中 **Master** 和 **PCM** 声道，按下<kbd>m</kbd> 键解除静音（静音状态下其显示有`mm`字样）使用<kbd>↑</kbd>方向键增加音量。

或者直接使用以下命令解除静音：

```shell
amixer sset Master unmute
```

## 双显卡管理

更多内容可参看[双显卡管理](../laptop笔记本相关.md#显卡管理)

- 显卡切换

  在Linux中可使用以下方法来切换显卡。参看相关资料：

  - [prime](https://wiki.archlinux.org/index.php/PRIME_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)（NVIDIA和ATI均支持）
  - [NVIDIA optimus](https://wiki.archlinux.org/index.php/NVIDIA_Optimus_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))如：
    - [bumblebee](https://wiki.archlinux.org/index.php/Bumblebee_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
    - [nvidia-xrun](https://github.com/Witko/nvidia-xrun)（该方案支持Vulkan接口）


- 关闭独显

  如果不需要运行大量耗费GPU资源的程序，可以禁用独立显卡，只使用核心显卡，一些禁用方法如：

  - 在BIOS中关闭独立显卡（不是所有设备都具有该功能）

  - 执行`echo OFF > /sys/kernel/debug/vgaswitcheroo/switch`临时关闭独立显卡（注意，如果使用了bbswtich那么应该是没有这个文件的！）。

  - 使用bbswitch

    ```shell
    #设置bbswitch模块参数
    echo 'bbswitch load_state=0 unload_state=1' > /etc/modprobe.d/bbswitch.conf
    #开机自动加载bbswitch模块
    echo 'bbswitch ' > /etc/modules-load.d/bbswitch.conf

    modprobe -r nvidia nvidia_modeset nouveau #卸载相关模块
    sudo mkinitcpio -p linux  #重新生成initramfs--系统引导时的初始文件系统
    ```

    可使用以下命令控制bbswitch进行开关显卡：

    ```shell
    sudo tee /proc/acpi/bbswitch <<<OFF  #关闭独立显卡
    sudo tee /proc/acpi/bbswitch <<<ON  #开启独立显卡
    ```

  - 屏蔽相关模块

    将独立显卡相关模块进行屏蔽，示例屏蔽NVIDIA相关模块。

    ```shell
    echo nouveau > /tmp/nvidia    #开源的nouveau
    lsmod | grep nvidia | grep -E '^nvidia'|cut -d ' ' -f 1 >> /tmp/nvidia    #闭源的nvidia
    sed -i 's/^\w*$/blacklist &/g' /tmp/nvidia  #添加为blacklist
    sudo cp /tmp/nvidia /etc/modprobe.d/nvidia-blacklist.conf  #自动加载

    modprobe -r nvidia nvidia_modeset nouveau #卸载相关模块
    sudo mkinitcpio -p linux  #重新生成initramfs--系统引导时的初始文件系统
    ```

    重启后检查NVIDIA开启情况：`lspci |grep NVIDIA`，如果输出内容后面的括号中出现了` (rev ff)` 字样则表示该显卡已关闭。

    注意：如果载入了其他依赖nvidia的模块，nvidia模块也会随之载入。

## 科学上网

- hosts：例如[googelhosts](https://github.com/googlehosts/hosts) 。

  执行`hosts`即可从指定网址更新。

- lantern：安装`lantern`

- [shadowsocks项目](https://github.com/shadowsocks)
  - [archwiki:shadowsock(简体中文)](https://wiki.archlinux.org/index.php/Shadowsocks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

  - socks代理 — proxychains

    配置：编辑/etc/proxychains.conf文件，设置`socks5 127.0.0.1 1080` 。

    使用：`proxychains [命令或者程序名]`

## SSD固态硬盘相关

参看：[Solid State Drives](https://wiki.archlinux.org/index.php/Solid_State_Drives_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和[ssd固态硬盘优化](../ssd固态硬盘优化.md)

## windows和linux统一使用UTC

Windows使用本地时间（Localtime），而Linux则使用UTC（Coordinated Universal Time ，世界协调时），建议更改windows注册表使windows也使用utc时间。
1. 在windwos新建文件`utc.reg`，写入：

```
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation]
"RealTimeIsUniversal"=dword:00000001
```
保存后，双击该文件运行，以写入注册表。

2. 重启系统，在BIOS中根据当地所用的标准时间来设置正确的UTC时间。（例如在中国使用的北京时间是东八区时间，根据当前北京时间，将BIOS时间前调8小时）。

## wayland

wayland不会读取.xprofile和xinitrc等xorg的环境变量配置文件，故而不要将某些软件的相关设置写入到上诉文件中，可写入/etc/profile、 /etc/bash.bashrc 和/etc/environment。参考[archwiki-wayland](https://wiki.archlinux.org/index.php/Wayland)、[archwiki-环境变量](https://wiki.archlinux.org/index.php/Environment_variables_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.AE.9A.E4.B9.89.E5.8F.98.E9.87.8F)和[wayland主页](https://wayland.freedesktop.org/)。

# 常用软件

###### 参考看：[archwiki:软件列表](https://wiki.archlinux.org/index.php/List_of_applications_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))、[awesome linux softwares](https://github.com/LewisVo/Awesome-Linux-Software)、[我的软件列表](../我的软件列表.md)、[gnome配置](../gnome配置.md)……