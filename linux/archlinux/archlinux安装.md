[TOC]

# 准备工作

- 划分一定量的磁盘空间用于linux安装（推荐至少30G）

- **在bios设置中关闭启设置中的安全启动**（如有没有该设置则略过，对archlinux使用安全启动可参考[archwiki-Secure Boot](https://wiki.archlinux.org/index.php/Secure_Boot_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)))

- **互联网**（安装需要联网）

- U盘（本文是使用u盘作为启动介质）

- [Arch Linux 系统镜像](https://www.archlinux.org/download/)（根据国家和地区选择网站下载会更快）

- nano或vim基本操作技能（安装过程中编辑配置文件）

- 启动盘制作

  - 如果设备支持[UEFI](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))，直接将下载的系统镜像文件解压或挂载，复制其中的内容到U盘根目录即可。

  - 使用工具制作启动盘

    - windows下可使用[usbwriter](https://sourceforge.net/projects/usbwriter/)、[poweriso](http://www.poweriso.com)、[winsetupfromusb](http://www.winsetupfromusb.com/)等工具。

    - Linux/OSX下可使用dd命令。示例：

      ```shell
      dd if=/path/arch.iso of=/dev/sdb bs=10M
      ```

      `/path/arch.iso`是archlinux的ISO文件的路径，`sdx`是U盘的设备编号如sda、sdb、sdc等（可插上优盘后在终端用`df -h`命令查看），`10M`是读写块的大小（默认512B）。

---

插上U盘启动盘 > 使用USB启动（不同设备方法设置不同）> 载入U盘上的系统 > 回车选择**第一项**（默认）进入 > 等待一切载入完毕……

# 基础安装

以下安装过程中遇到需要选择的地方，如不清楚如何选择，可直接回车。

## 系统分区

### 准备工作

在进行分区操作前或许要进行以下准备工作。

- 了解硬盘情况

  如果对设备硬盘分区情况不了解，可先了解分区情况，例如使用如下命令：

  ```shell
  lsblk  #列出所有可用块设备的信息
  fdisk -l /dev/sda  #使用fdisk工具查看sda的情况
  cfdisk  #使用cfdisk工具查看第一块硬盘的情况
  ```

- `cfdisk`分区工具使用简介

  推荐cfdisk，相比parted等工具更为直观，上手容易。

  - 查看整个磁盘的情况 `cfdisk /dev/sda` （第二块硬盘则是`cfdisk /dev/sdb` ）
  - 利用箭头进行上下左右移动，选中项会高亮显示，回车键确定操作。
  - `New`用于新建分区，输入新建分区的大小并回车，建立了一个分区。
  - `Delete`删除当前选中的分区。
  - `Type`选择分区类型。
  - `Write`用于保存操作。
  - `quit`退出（直接输入`q`亦可）。

- 分区表选择

  如果硬盘未进行划分，执行`cfdisk`会提示选择分区方式，如果设备支持[GPT](https://wiki.archlinux.org/index.php/Partitioning_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E9.80.89.E6.8B.A9GPT_.E8.BF.98.E6.98.AF_MBR)则建议使用GPT 。

  如果已经是mbr分区表，而希望采用gpt分区表，可使用parted重建：

  ```shell
  parted /dev/sda  #进入parted命令行
  mklable  #建立分区表，系统会询问采用什么格式
  gpt  #输入gpt回车即可
  ```

  附注：老一代的系统用的MBR+BIOS的方式，MBR 分区表加主板上的 BIOS 引导；如今大多数设备都采用GPT+EFI的方式。更多内容参看[分区表](https://zh.wikipedia.org/wiki/%E5%88%86%E5%8C%BA%E8%A1%A8)。

- 各linux分区规划

  本文中规划以下几个分区和建议大小：

  - boot  引导  200M+  

    已经足够装下好几个系统引导文件

  - root  系统根目录  20G+

    视具体使用情况而定，如过作为日常使用，要安装不少工具，建议20G+

  - swap  交换空间  4G+

    物理内存很大也可以不划分。需要进行大量使用内存的操作而可能造成内存耗尽建议划分，要使用休眠功能必须划分。

  - home  用户家目录

    **如果作为日常使用需要存放文件，当然越大越好。**

    即使不怎么在该目录存放文件也建议至少划分4G+，因为用户的各种配置和应用缓存（如浏览器）将会存在该目录中。

### 建立分区

注意：**下文中sdx是本文中的示例，请根据实际情况更换。**

- boot分区

  使用efi系统分区或者不使用efi系统分区采取不同操作：

  - 使用[EFI系统分区](https://wiki.archlinux.org/index.php/EFI_System_Partition_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))（**EFI system partition，简称esp**）

    GPT使用esp引导系统，将esp挂载到`/boot` 目录，引导文件将置于该目录下。根据具体情况操作：

    - 使用已经存在的esp

      如果设备上已经安**装有其他系统**（例如已经有一个Windows）且打算保留，则**不要对该esp进行格式化**（否则会造成其他系统无法启动），无需任何操作，直接跳到下一步“**root、home和swap分区**”。

      如果不保留其他系统的引导文件，可在[挂载分区](#挂载分区)后，删除/mnt/boot文件夹中的内容。

      ---

      提示：

      安装windows时，其默认的eps大小为100M，容量略小（但也足够放下一个windows+一个ArchLinux的引导文件）。

      如果容量不足，可使用windows硬盘管理工具（或使用其他工具）将esp扩大（可酌情将esp相邻的windows esr分区缩小）。

      如果实在空间不足又难以扩容，可考虑重新建立一个esp分区，将esp中原有文件备份，在安装完毕后，将其中内容复制到新建立的esp分区中（或使用windows引导修复工具进行修复）。

      ---

    - 新建立esp

      则使用cfdisk创建一个**类型为`EFI system`的分区**（以下假设esp使用`/dev/sda1`） ，并对其格式化：

      ```shell
      mkfs.vfat /dev/sda1    # 格式化esp
      ```
      提示：如果使用lvm分区方法，并且打算使用grub作为引导程序，可以将esp放到lvm中；但是**如果还要在esp中放置windows引导文件，则不能将该esp放在lvm中**。

  - 不使用EFI系统分区

    使用cfdisk新建一个boot分区，并对其格式化：

    ```shell
    mkfs.vfat /dev/sda1    # 格式化esp
    ```

    提示：在linux中，boot分区可以是主分区，也可以是扩展分区中的逻辑分区（其他分区亦同）。



- root、home和swap分区

  选择标准分区方式或者lvm弹性分区方式：

  - 标准分区方式

    使用`cfdisk`新建各个分区，然后格式化各个分区：

    ```shell
      mkfs.ext4 /dev/sda2    #格式化root
      mkfs.ext4 /dev/sda3    #格式化home
      mkswap /dev/sda4       #格式化swap
    ```

  - [LVM](https://wiki.archlinux.org/index.php/LVM_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))分区方式

    先用`cfdisk`建立一个分区（假设为`/dev/sda2` ），再**建立物理卷->建立卷组->建立逻辑卷**：

    ```shell
    #1.建立物理卷：在 /dev/sda2建立物理卷
    pvcreate /dev/sda2
    #2.建立卷组：新建名为linux的卷组 并 将sda2加入到卷组中
    vgcreate linux /dev/sda2
    #3.建立逻辑卷：在linux卷组中建立root、swap和home逻辑卷
    lvcreate -L 30G linux -n root
    lvcreate -L 4G linux -n swap
    lvcreate -L 100G linux -n home
    # lvcreate -l +100%FREE linux -n home  #3.2.1  用linux卷组中所有剩余空间建立home逻辑卷
    #4.格式化各个逻辑卷
    mkfs.ext4 /dev/mapper/linux-root    #格式化root
    mkfs.ext4 /dev/mapper/linux-home    #格式化home
    mkswap /dev/mapper/linux-swap       #格式化swap
    ```

### 挂载分区

根据不同的分区方式进行挂载操作：

- 标准分区方式

  ```shell
  mount /dev/sda2 /mnt         #挂载root分区
  mkdir /mnt/boot /mnt/home    #建立boot和home挂载点
  mount /dev/sda1 /mnt/boot    #挂载esp到/boot
  mount /dev/sda3 /mnt/home    #挂载home分区到/home
  swapon /dev/sda4        #激活swap
  ```


- lvm分区方式

  ```shell
  mount /dev/mapper/linux-root /mnt    #挂载root分区
  mkdir /mnt/boot /mnt/home    #建立boot和home挂载点
  mount /dev/sda1 /mnt/boot    #挂载esp到/boot
  mount /dev/mapper/linux-home /mnt/home    #挂载home逻辑卷到/home
  swapon /dev/mapper/linux-swap    #激活swap
  ```

## 连接网络

```shell
dhcpcd    #连接到有线网络
wifi-menu    #连接到无线网络 执行后会扫描网络 选择网络并连接即可
ping -c 5 z.cn  #可测试连接情况
```

## 配置镜像源

在安装前最好选择较快的镜像，以加快下载速度。
编辑` /etc/pacman.d/mirrorlist`，选择首选源（按所处国家地区关键字索搜选择，如搜索china），将其添加到文件开头，保存并退出。一些中国地区镜像源如：

```shell
Server = https://mirrors.ustc.edu.cn/archlinux/repo/os/arch
Server = https://mirrors.163.com/archlinux/repo/os/arch
```

## 安装基础系统

```shell
pacstrap /mnt base base-devel
```
## 建立fstab文件

```shell
genfstab -U /mnt > /mnt/etc/fstab
cat /mnt/etc/fstab    # 检查生成的 /mnt/etc/fstab 文件是否正确
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
  useradd -m -g users -s /bin/bash user1    #添加名为user1的普通用户
  passwd user1    #设置或更改user1用户密码 接着输入两次密码
  ```


- 给予普通用户sudo权限

  ```shell
  chmod u+w /etc/sudoers
  echo  'user1 ALL=(ALL) ALL' >> /etc/sudoers    #将user1加入sudo
  ```


## 时间

保留windows用户可能还需要**参考后文[windows和linux统一使用UTC](#windows和linux统一使用UTC)** 。

linux时钟分为系统时钟（system clock）和硬件时钟（Real Time Clock, RTC——即实时时钟，电脑主板记上的时钟）。

设置时区，将系统时间和硬件时间统一：

```shell
date #查看当前系统时间
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime    # 设置时区 示例为中国东八区标准时间--Asia/Shanghai
hwclock -w -u    #将当前系统时间写入到硬件时钟  并使用utc时间（推荐）
# hwclock -s -u  #将当前硬件时间写入到系统时钟  并使用utc时间
```

## 主机名

```shell
#MyPC是要设置的主机名
echo MyPC > /etc/hostname
#或者
hostname MyPC
```

**注意:** 在 Arch Linux chroot 安装环境中，*hostnamectl*不起作用，因此不能使用`hostnamectl set-hostname 主机名`设置主机名。

## 网络配置

```shell
systemctl enable dhcpcd    #开机自启动有线网络  当然也可以手动执行 dhcpcd 连接
pacman -S iw wpa_supplicant dialog    #无线网络需要安装这些工具使用wifi-menu联网
```

参看archlinux-wiki的[netctl](#https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和[网络配置](https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))了解更多。

注意：linux自带的`linux-frimware`已经支持大多数驱动，如果某些设置不能使用，参看[archwiki:网络驱动](https://wiki.archlinux.org/index.php/Wireless_network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.AE.89.E8.A3.85_driver.2Ffirmware)

## 系统引导

- 引导工具

  ```shell
  pacman -S grub
  ```

  - 使用EFI系统分区

    ```shell
    pacman -S efibootmgr  #使用esp还需安装
    grub-install --efi-directory=/boot --bootloader-id=grub
    ```

   - 不使用EFI系统分区（BIOS+MBR）

     ```shell
     grub-install --target=i386-pc /dev/sda
     ```

- 如果使用**intel CPU**最好也安装[微码](https://wiki.archlinux.org/index.php/Microcode_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))工具

  ```shell
  pacman -S intel-ucode
  ```

- 如过要引导多系统安装

  ```shell
  pacman -S os-prober
  ```

- 生成引导

   ```shell
   grub-mkconfig -o /boot/grub/grub.cfg
   ```


**注意**：os-prober可能需要在系统安装完毕后，**重启**进入系统**再次执行**引导**生成配置**命令就能检测到其他系统。

---

至此**基础系统**安装完成，可以**连续按两次`ctrl`+`d` ，输入`reboot`重启并拔出u盘**。当然也可以继续进行下面的安装流程。

如果windows+archlinux双系统用户在重启后直接进入了Windows系统，可参看[选择grub为第一启动项](#选择grub为第一启动项) 解决。

# 常用配置

## 图形界面

### 显卡驱动

首先需要了解设备的显卡信息，也可是使用`lspci | grep VGA`查看。根据显卡情况安装驱动：

```shell
pacman -S xf86-video-vesa     #通用显卡
pacman -S xf86-video-intel     #intel核心显卡  可不安装 内核中已经集成开源实现
pacman -S nvidia                       #nvidia显卡驱动（包含vulkan）
pacman -S mesa                       #amd显卡使用开源mesa驱动即可
#vulkan 支持
#pacman -S vulkan-intel    #intel显卡
#pacman -S vulkan-radeon    #amd/ati显卡
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

窗口管理还需要自行配置[显示管理器](https://wiki.archlinux.org/index.php/Display_manager_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和[xinitrc](https://wiki.archlinux.org/index.php/Xinitrc_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)) 。

### 字体

参看[archwiki:fonts](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))选择安装字体。

- 终端等宽字体，如`ttf-dejavu`
- 数学和符号字体，如`ttf-symbola`（符号中也包含emoji表情，另外`noto-fonts-emoji` 是noto字体的emoji表情符号包）
- 中文字体参看下文[中文显示](#中文显示)。

### 中文本地化

参看[ArchLinux中文本地化](https://wiki.archlinux.org/index.php/Arch_Linux_Localization_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

- [Locale](https://wiki.archlinux.org/index.php/Locale_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)) 设置

编辑`/etc/locale.gen`，根据本地化需求移除对应行前面的注释符号。

以中文用户常用locale为例，选择英文（美国）UTF-8、简体中文GBK、简体中文UTF-8和繁体中文UTF-8，去掉这些行之前前面#号：

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

#### 中文显示

选择一款（或多款）中文字体安装，如：

```shell
pacman -S wqy-micorhei    #文泉驿微米黑
pacman -S adobe-source-han-sans-cn-fonts    # 思源黑体
pacman -S ttf-arphic-uming    #文鼎明体
```

更多字体参看[中日韩越字体](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E4.B8.AD.E6.97.A5.E9.9F.A9.E8.B6.8A.E6.96.87.E5.AD.97) 。安装思源黑体全集（或noto fonts cjk）而出现的中文显示异体字形的问题，参看该文的[修正简体中文显示为异体（日文）字形](https://wiki.archlinux.org/index.php/Arch_Linux_Localization_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E4.B8.AD.E6.96.87.E5.AD.97.E4.BD.93) 。

#### 中文输入

可选择[fcitx](https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))或[ibus](https://wiki.archlinux.org/index.php/IBus_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))。

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
  pacman -S ibus-libpinyin    #智能拼音（支持搜狗词库）
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
  pacman -Ss <word>  #查询有某关键字的软件 <word>即是要查询的关键字
  pacman -R <package-name>   #移除某软件但不移除其依赖
  pacman -Qi name  #查看已经安装的某软件的信息
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

**桌面用户无需安装**，窗口管理器用户安装：

```shell
pacman -S xf86-input-synaptics
```
### 蓝牙

**桌面用户忽略该小节**。窗口管理器用户：

```shell
pacman -S bluez
systemctl enable bluetooth
usermod -aG lp user1    #user1是当前用户名
```
蓝牙控制：命令行控制安装`bluez-utils`，使用参考[通过命令行工具配置蓝牙](https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E9.80.9A.E8.BF.87.E5.91.BD.E4.BB.A4.E8.A1.8C.E5.B7.A5.E5.85.B7.E9.85.8D.E7.BD.AE.E8.93.9D.E7.89.99)；或者安装[蓝牙图形界面工具]((https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#.E5.9B.BE.E5.BD.A2.E5.8C.96.E5.89.8D.E7.AB.AF))如`blueberry`。

### NTFS分区

桌面环境的文件管理器一般都能读取NTFS分区的内容，但不一定能能够写入。可使用`ntfs-3g`挂载：

```shell
pacman -S ntfs-3g       #安装
mkdir /mnt/ntfs          #在/mnt下创建一个名为ntfs挂载点
lsblk                                 #查看要挂载的ntfs分区 假如此ntfs分区为/dev/sda5
ntfs-3g /dev/sda5 /mnt/ntfs       #挂载分区到/mnt/ntfs目录
```
### U盘和MTP设备

**桌面环境一般能自动挂载**。窗口管理器用户：

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

使用 ← 和 → 方向键移动，选中 Master 和 PCM 声道，按下 m 键解除静音（静音状态下其显示有`mm`字样）使用 ↑ 方向键增加音量。

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

参考看：[archwiki:软件列表](https://wiki.archlinux.org/index.php/List_of_applications_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))、[awesome linux softwares](https://github.com/LewisVo/Awesome-Linux-Software)、[我的软件列表](../我的软件列表.md)、[gnome配置](../gnome配置.md)……