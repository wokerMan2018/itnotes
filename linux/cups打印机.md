添加网络打印机
安装cups相关组件（具体包名以实际为准）：
- cups
- cups-pdf  虚拟pdf打印机（可将打印任务输出为pdf文件）
- ghostscript  语言解释器
- gsfonts  用于ghostscript的type字体
- hpoj和hplip  惠普系列设备建议安装
- splix  三星系列设备建议安装
- guterprint  常见打印机设备的驱动几何（cannon epson sony lexmark olympus等等）
- bluez-cups  支持蓝牙功能的打印设备

浏览器访问localhost:631。
进入Administration项，添加打印机Add Printer（如需登录，使用root账户登录即可），选择**LPD/LPR Host or Printer**
在Connection中使用lpd协议连接打印机，格式：
```
lpd://打印机IP/queue
```
而后continue，填写打印机信息后，Continue，根据打印机型号选择ppd。

当然也可以使用其他管理前端如：
- print-manager  用于plasma（kde）的打印机设备管理工具
- simple-scan  用于gnome桌面的扫描仪管理工具
