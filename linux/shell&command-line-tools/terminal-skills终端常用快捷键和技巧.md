终端常用快捷键和小技巧

------

一些命令输入后需要回车执行。前即是左，后即是右。

基本

-   **使用通配符**
-   使用**<kbd>tab</kbd>补全**

# 程序状态

- <kbd>Ctrl</kbd> <kbd>c</kbd>  发送SIGINT 信号给前台进程组中的所有进程

  - 终止前台进程
  - 结束当前正在输入的行

- <kbd>Ctrl</kbd> <kbd>\</kbd>  发送SIGOUT 信号给前台进程组中的所有进程并生成coredump

  终止前台进程

- <kbd>Ctrl</kbd> <kbd>z</kbd>  发送 SIGTSTP 信号给前台进程组中的所有进程

  挂起（暂停）前台进程

  使用`fg`恢复最近一个挂起的进程

  使用`bg`将最近一个挂起的进程放到后台执行（作用相当于在命令后添加`&`）

- <kbd>Ctrl</kbd> <kbd>d</kbd>  一个特殊的二进制值，表示 EOF，作用类似于`exit`命令。

- <kbd>Ctrl</kbd> <kbd>s</kbd> 和 <kbd>Ctrl</kbd> <kbd>q</kbd>  分别为暂停控制台输出 和 恢复暂停的控制台输出

- <kbd>Ctrl</kbd> <kbd>l</kbd> 或`clear`  清除屏幕内容

## 后台执行程序

- `&`放入后台

  - 命令+&

    执行命令后，<kbd>Ctrl</kbd> <kbd>z</kbd>，再`bg`类似命令+&的方式。

  - `nohup`+命令+&
- 使用其他工具如`screen` 或 `tmux`

# 历史命令

`history`查看历史命令，内容保存在`~/.bash_history`，`/etc/profile`中可以设定历史命令保存条数。

- history参数

  - -c  清空历史命令

  - -w  把缓存中的历史命令立即保存

    提示：本次登录shell历史命令将在登出此次shell后加入历史，可使用`history -w`立即写入。

- 退出shell不保存此次操作历史到history

  - `kill -9 $$`

- <kbd>Ctrl</kbd> <kbd>r</kbd>   搜索历史命令

## 命令复用

- <kbd>Alt</kbd> <kbd>.</kbd>  执行上一条命令
- 上箭头或<kbd>Ctrl</kbd> <kbd>p</kbd>  切换到上一条命令
- 下箭头或<kbd>Ctrl</kbd> <kbd>n</kbd>  切换到下一条命令
- <kbd>page-up</kbd>、<kbd>page-down</kbd>分别是切换到第一条命令、最后一条（最近一条）命令
- !! （两个叹号）重复上一次命令 （可以用在sudo/su后面表示用sudo/su重复执行一次）
    -   !$      其中的美元符号会被替换成上一条命令的最后一个单词
    -   !^      其中的上尖括号会被替换成上一条命令的第一个单词
    -   !n      执行历史中第n条命令
    -   !字串    执行以该字串开头的命令

# 终端快捷键

## 删除

在vim编辑模式中依然适用。

-   <kbd>Ctrl</kbd> <kbd>h 前删除（同backspace键）

-   <kbd>Ctrl</kbd> <kbd>d 后删除（同delete键）

-   <kbd>Ctrl</kbd> <kbd>w 删除光标前面一个单词

-   <kbd>Ctrl</kbd> <kbd>u 删除光标前面所有内容

-   <kbd>Ctrl</kbd> <kbd>k 删除光标后面所有内容

## 替换和对调

### 大小写转换

*该单词即是光标坐在的单词*

-   <kbd>Alt</kbd> u  将**该单词中**光标所在位置及其后的字母变为大写(upper case)
-   <kbd>Alt</kbd> l   将**该单词中**光标所在位置及其后的字母变为小写(lower case)
-   <kbd>Alt</kbd> c  将**该单词中**光标所在位置变为大写 其后的字母变为小写——即首字母大写(captial)

### 位置对调

**注意**：

终端可能能够选择光标样式，如方块光标会覆盖整个字符，下划线光标会标示在整个字符下面，而竖线光标则出现在两个字符中间，下面是以竖线光标做的说明。方块光标和下划线光标以光标左侧边缘作为判定前后的参照位置。

**空格/tab内容也算字符**。

- <kbd>Ctrl</kbd> <kbd>t</kbd>

  - 当光标在字符间时，**对调光标前后两个字符的位置**且光标后移一位（transposition)
  - 当光标在所有字符末尾时，对调最后两个字符位置

  **注意**：在方块和下划线光标里，这句话中的1应该描述为：

  光标在字符上时，对调光标所在字符和光标前一个字符的位置

- <kbd>Alt</kbd> t  对调单词，规则参照<kbd>Ctrl</kbd> <kbd>t</kbd>

## 选择、复制和粘贴

- <kbd>Shift</kbd> <kbd>Ctrl</kbd>  <kbd>c</kbd>  复制
- <kbd>Shift</kbd> <kbd>Ctrl</kbd>  <kbd>v</kbd>粘贴

## 移动光标

-   <kbd>Ctrl</kbd> <kbd>a</kbd> 移动到开始（同home键）
-   <kbd>Ctrl</kbd> <kbd>e</kbd> 移动到结尾（同end键）
-   <kbd>Ctrl</kbd> <kbd>f</kbd> 向前移动一个字符（同右方向键）
-   <kbd>Ctrl</kbd> <kbd>b</kbd> 向后移动一个字符（同左方向键）
-   <kbd>Alt</kbd> <kbd>f</kbd> 像前移动到下一个单词尾部
-   <kbd>Alt</kbd> <kbd>b</kbd> 向后移动到上一个单词首部
-   <kbd>Ctrl</kbd> <kbd>⬅</kbd> 移动到当前单词结尾
-   <kbd>Ctrl</kbd> <kbd>➡</kbd> 移动到当前单词开头
-   <kbd>Ctrl</kbd> <kbd>x</kbd> <kbd>x</kbd>  在最后两次光标出现的位置间切换
