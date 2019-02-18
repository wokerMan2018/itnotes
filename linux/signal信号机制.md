信号是linux系统为了响应某些状况而产生的事件，进程收到信号后应该采取相应的动作。

Linux信号机制基本上是从Unix系统中继承过来的。

> **信号**（英语：Signals）是[Unix](https://zh.wikipedia.org/wiki/Unix)、[类Unix](https://zh.wikipedia.org/wiki/%E7%B1%BBUnix)以及其他[POSIX](https://zh.wikipedia.org/wiki/POSIX)兼容的操作系统中[进程间通讯](https://zh.wikipedia.org/wiki/%E8%BF%9B%E7%A8%8B%E9%97%B4%E9%80%9A%E8%AE%AF)的一种有限制的方式。它是一种[异步](https://zh.wikipedia.org/wiki/%E7%95%B0%E6%AD%A5)的通知机制，用来提醒[进程](https://zh.wikipedia.org/wiki/%E8%BF%9B%E7%A8%8B)一个事件已经发生。

# 信号来源

- 硬件来源
  - 硬件设备操作（例如按下键盘）
  - 硬件故障

- 软件来源

  - 调用系统函数（如kill, raise, alarm和setitimer以及sigqueue）
  - 非法运算
  - 非法内存
  - 环境切换（比如从用户态切换到其他态）

  ……

# 信号种类

使用`kill -l`可以查看系统支持的信号类型。每个信号都有一个编号和一个宏定义名称，这些宏定义可以在signal.h中找到。

根据信号来源不同也可将其简单分类：

- 程序错误：除零，非法内存访问… 
- 外部信号：终端Ctrl-C产生SGINT信号，定时器到期产生SIGALRM… 
- 显式请求：kill函数允许进程发送任何信号给其他进程或进程组



根据规范标准可分为POSIX标准信号和非POSIX标准信号：

POSIX标准信号

| 信号      | 取值     | 默认动作 | 含义（发出信号的原因）                 |
| --------- | -------- | -------- | -------------------------------------- |
| SIGHUP    | 1        | Term     | 终端的挂断或进程死亡                   |
| SIGINT    | 2        | Term     | 来自键盘的中断信号                     |
| SIGQUIT   | 3        | Core     | 来自键盘的离开信号                     |
| SIGILL    | 4        | Core     | 非法指令                               |
| SIGABRT   | 6        | Core     | 来自abort的异常信号                    |
| SIGFPE    | 8        | Core     | 浮点例外                               |
| SIGKILL   | 9        | Term     | 杀死                                   |
| SIGSEGV   | 11       | Core     | 段非法错误(内存引用无效)               |
| SIGPIPE   | 13       | Term     | 管道损坏：向一个没有读进程的管道写数据 |
| SIGALRM   | 14       | Term     | 来自alarm的计时器到时信号              |
| SIGTERM   | 15       | Term     | 终止                                   |
| SIGUSR1   | 30,10,16 | Term     | 用户自定义信号1                        |
| SIGUSR2   | 31,12,17 | Term     | 用户自定义信号2                        |
| SIGCHLD   | 20,17,18 | Ign      | 子进程停止或终止                       |
| SIGCONT   | 19,18,25 | Cont     | 如果停止，继续执行                     |
| SIGSTOP   | 17,19,23 | Stop     | 非来自终端的停止信号                   |
| SIGTSTP   | 18,20,24 | Stop     | 来自终端的停止信号                     |
| SIGTTIN   | 21,21,26 | Stop     | 后台进程读终端                         |
| SIGTTOU   | 22,22,27 | Stop     | 后台进程写终端                         |
|           |          |          |                                        |
| SIGBUS    | 10,7,10  | Core     | 总线错误（内存访问错误）               |
| SIGPOLL   |          | Term     | Pollable事件发生(Sys V)，与SIGIO同义   |
| SIGPROF   | 27,27,29 | Term     | 统计分布图用计时器到时                 |
| SIGSYS    | 12,-,12  | Core     | 非法系统调用(SVr4)                     |
| SIGTRAP   | 5        | Core     | 跟踪/断点自陷                          |
| SIGURG    | 16,23,21 | Ign      | socket紧急信号(4.2BSD)                 |
| SIGVTALRM | 26,26,28 | Term     | 虚拟计时器到时(4.2BSD)                 |
| SIGXCPU   | 24,24,30 | Core     | 超过CPU时限(4.2BSD)                    |
| SIGXFSZ   | 25,25,31 | Core     | 超过文件长度限制(4.2BSD)               |


非POSIX标准信号
| 信号      | 取值     | 默认动作 | 含义（发出信号的原因）     |
| --------- | -------- | -------- | -------------------------- |
| SIGIOT    | 6        | Core     | IOT自陷，与SIGABRT同义     |
| SIGEMT    | 7,-,7    |          | Term                       |
| SIGSTKFLT | -,16,-   | Term     | 协处理器堆栈错误(不使用)   |
| SIGIO     | 23,29,22 | Term     | 描述符上可以进行I/O操作    |
| SIGCLD    | -,-,18   | Ign      | 与SIGCHLD同义              |
| SIGPWR    | 29,30,19 | Term     | 电力故障(System V)         |
| SIGINFO   | 29,-,-   |          | 与SIGPWR同义               |
| SIGLOST   | -,-,-    | Term     | 文件锁丢失                 |
| SIGWINCH  | 28,28,20 | Ign      | 窗口大小改变(4.3BSD, Sun)  |
| SIGUNUSED | -,31,-   | Term     | 未使用信号(will be SIGSYS) |

说明：一些信号的取值是硬件结构相关，一般alpha和sparc架构用第一个值，i386、ppc和sh架构用中间值，mips架构用第三个值， - 表示相应架构的取值未知。

# 信号发送

发送信号的方法：

- 键盘操作（这些组合键可以通过[stty](https://zh.wikipedia.org/w/index.php?title=Stty&action=edit&redlink=1)命令来修改）

  - <kbd>Ctrl</kbd> <kbd>c</kbd>  发送SIGINT信号。默认情况下会导致进程终止。
  - <kbd>Ctrl</kbd> <kbd>z</kbd>  发送SIGTSTP信号。默认情况下会导致进程[挂起](https://zh.wikipedia.org/wiki/%E6%8C%82%E8%B5%B7)。
  - <kbd>Ctrl</kbd> <kbd>`\`</kbd>  发送SIGQUIT信号。默认情导致进程终止并且将内存中的信息转储到硬盘（core文件，[核心转储](https://zh.wikipedia.org/wiki/%E6%A0%B8%E5%BF%83%E8%BD%AC%E5%82%A8)）。

- 调用系统函数

  发送信号的主要函数有：kill()、raise()、 sigqueue()、alarm()、setitimer()以及abort()。

- 软件条件产生的信号（如alarm函数）

# 信号处理

linux内核处理（递达）信号的方式

- **忽略**信号：对信号不做任何处理。

  不能被忽略的信号：SIGKILL 和 SIGSTOP

- **捕捉**信号：定义信号处理函数，当信号发生时，执行相应的处理函数。

  ​不能被捕捉的信号：SIGKILL 和 SIGSTOP	

- 执行默认操作：Linux对每种信号都规定了默认操作（参看[信号种类](#信号种类)）

# 信号阻塞和未决
- 信号递达Delivery：实际执行信号的处理动作
- 信号未决Pending：信号从产生到递达之间的状态
- 阻塞Block：进程可以选择阻塞某个信号
  被阻塞的信号产生时保持在未决状态，直到进程解除对此信号的阻塞，才执行递达的动作。

# 信号生命周期

信号生命周期是从信号发送到信号处理函数的执行完毕整个阶段。

一个完整的信号生命周期可以分为三个重要的阶段，相邻两个事件的时间间隔构成信号生命周期的一个阶段：

1. 信号诞生
2. 信号在进程中注册完毕
3. 信号在进程中的注销完毕
4. 信号处理函数执行完毕