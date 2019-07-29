# stty终端设置

获取和设置终端命令行的相关信息。

## 获取终端信息

```shell
stty -a  #以容易阅读的方式打印当前的所有配置
stty size  #打印终端行数和列数  另外全局变量$LINES和$COLUMNS也可获取
```

## 设置终端示例

- 改变 Ctrl D 按键作用(默认表示文件结束)

  ```shell
  stty eof "string"
  ```

- 屏蔽和恢复回显（echo）

  ```shell
  stty -echo  #此后输入内容均不会显示
  stty echo  #恢复回显
  ```

- 忽略和恢复回车符

  ```shell
  stty igncr     #开启
  stty -igncr    #恢复
  ```

- 禁止个恢复小写输出

  ```shell
  stty olcuc #开启
  stty -olcuc#恢复
  ```

# tput操纵终端显示

>  **tput命令**将通过 terminfo 数据库对您的终端会话进行初始化和操作。通过使用 tput，您可以更改几项终端功能，如移动或更改光标、更改文本属性，以及清除终端屏幕的特定区域。

## 获取终端信息

```shell
tput lines  #获取终端行数(高)
tput cols  #获取终端列数(宽)
```

## 设置终端

```shell
tput init  #初始化终端
tput reset #重置终端
```

### 光标cusor

- 位置控制

  ```shell
  tput sc # 保存当前光标位置
  tput rc # 恢复保存的光标位置 restore
  ```

  使用 cup 选项，在各行和各列中将光标移动到任意 X 或 Y 坐标（设备左上角的坐标为 (0,0)）。

  ```shell
  tput cup 10 13 # 将光标移动到指定行列位置 10列 13行
  ```

  示例，定位光标到指定位置输出提示信息后，再将光标恢复到原来的位置等待用户输入内容：

  ```shell
  #最终看到右下角部分有一句提示信息，而光标在原来位置等待输入
  (tput sc ; tput cup 23 45 ; echo “Input from tput/echo at 23/45” ; tput rc)
  ```

  保存光标位置--->移动光标到指定位置--->输出提示内容--->恢复保存的光标位置。

  另，清楚屏幕内容（作用同clear)

  ```shell
  tput clear # 清屏
  ```

- 光标属性

  ```shell
  tput civis # 光标不可见 invisiable
  tput cnorm # 光标可见 normal
  ```

### 文本text

更改文本的显示属性（如颜色、字体等）

- 配色选项

  分配的数值与颜色的对应关系（可能会因 UNIX 系统的不同而异）：
  
  >0：黑色
  >
  >1：蓝色
  >
  >2：绿色
  >
  >3：青色
  >
  >4：红色
  >
  >5：洋红色
  >
  >6：黄色
  >
  >7：白色
  - `setb`  设置背景色background color
  - `setf`   设置前景色foreground color
  - `rev`   反色（反显当前配色方案，即对调前景色和背景色）

- 样式选项

  - `bold`  粗体模式
  - `dim`  半透明模式
  - `smul`和`rmul` 下划线underline模式和取消下划线模式remove underline

- 其他

  - `smso`和`rmso`  开启标准输出模式standout和取消标准输出模式
  - `sgr0`  关闭所有设置的属性


```shell
tput rev ;echo "hello ukelele";tput sgr0  #下一行hello ukelele会反色

bold=$(tput bold)
echo -e "$bold Bold Texts$(tput sgr0)"  #粗体显示Bold Texts文字 
```

