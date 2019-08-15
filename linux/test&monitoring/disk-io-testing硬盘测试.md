# io监控工具

- iotop
- iostat

# 测试工具

## dd

```shell
if=/dev/zearo  #读取的文件
of=test_file     #写入到该文件
bs=4k                #block size  每个块文件的大小
count=64k      #块文件个数 64k=64000
time dd if=/dev/zero of=$of bs=$bs count=$count oflag=dsync
```

if文件也可以是已经存在的一个文件。（创建一个测试用的大文件可以使用`fallocate -l <size> <filename>`。）

of文件位于要测试的硬盘的挂载目录中。

oflag值为dsync，表示使用同步I/O，每次读取bs指定的块文件大小的内容后，就要立即将其写入硬盘，再读取下一个bs指定大小的块文件，可以去除缓存的影响。

## iozone

> IOZONE主要用来测试操作系统文件系统性能的测试工具。使用iozone可以在多线程、多cpu，并指定cpu cache空间大小以及同步或异步I/O读写模式的情况下进行测试文件操作性能。

iozone可测试项包括：Read, write, re-read,re-write, read backwards, read strided, fread, fwrite, random read, pread,mmap, aio_read, aio_write 。

通常情况下，测试的文件大小要求至少是系统cache的两倍以上，测试的结果才是真是可信的。如果小于cache的两倍，文件的读写测试读写的将是cache的速度，测试的结果大打折扣。 

iozone的测试以表格形式输出：顶部横行为每次读/写的块文件大小（单位Kbytes），左侧纵列为测试文件的大小（单位Kbytes），其余为对应的读写速度。

常用参数

- `-a`   全自动测试  测试记录块大小从4k到16M，测试文件从64k到512M
  - `-A`  全面测试 没有记录块的范围限制



- `-R`  产生Excel到标准输出 
- `-b`  指定输出文件的名字 和`-R`合用以输出xls文件



- `-s <file size>`  指定固定的测试文件大小
- `-r <block size>`  指定固定的测试的文件块大小

- `-n <min size> -g <max size>`  指定测试文件的大小范围
- `-y <min size> -q <max size>`  指定测试文件块的大小范围

- `-f <file name>`  测试文件的名字（改文件必须位于测试硬盘中)
- `-F <file1> [file2...fileN] `  测试多线程指定的文件名
  - `-t <N>`  线程数量



- `-c`  测试包括文件的关闭时间

  测试网络文件系统如NFS，可使用`-c`参数，这通知iozone在测试过程中执行close()函数。使用close()将减少NFS客户端缓存的影响。

  **如果测试文件比内存大，就没有必要使用参数-c**。

- `-C`  显示每个节点的吞吐量



- `-D`  对mmap文件使用msync异步写

- `-i <N>`  选择测试项N，N的取值及其意义：

  - 0 write/rewrite

  - 1 read/re-read

  - 2 random-read/write

  - 3 Read-backwards

  - 4 Re-write-record

  - 5 stride-read

  - 6 fwrite/re-fwrite

  - 7 fread/Re-fread

  - 8 random mix

  - 9 pwrite/Re-pwrite

  - 10=pread/Re-pread

  - 11=pwritev/Re-pwritev   12=preadv/Re-

     

---

各种测试的含义

- Write: 测试向一个新文件写入的性能。

  当一个新文件被写入时，除了需要存储文件本身的数据内容，还需要定位数据存储在存储介质的具体位置的额外信息——即“元数据”，包括目录信息，所分配的空间和其他与该文件有关但又并非该文件所含数据的其他数据。

- Re-write: 测试向一个已存在的文件写入的性能。

  当一个已存在的文件被写入时，因为元数据已经存在，Re-write的性能通常比Write的性能高。

- Read: 测试读一个已存在的文件的性能。

- Re-Read: 测试读一个最近读过的文件的性能。

  因为操作系统通常会缓存最近读过的文件数据，Re-Read性能会高一些。

- Random Read: 测试读一个文件中的随机偏移量的性能。

  影响因素：操作系统缓存的大小，磁盘数量，寻道延迟等。

- Random Write: 测试写一个文件中的随机偏移量的性能。

  影响因素：操作系统缓存的大小，磁盘数量，寻道延迟等。

- Random Mix: 测试读写一个文件中的随机偏移量的性能。

  影响因素：操作系统缓存的大小，磁盘数量，寻道延迟等。

  该测试只有在吞吐量测试模式下才能进行。每个线程/进程运行读或写测试。这种分布式读/写测试是基于round robin 模式的，最好使用多于一个线程/进程执行此测试。

- Backwards Read: 测试使用倒序读一个文件的性能。

  极少应用程序会使用倒序读文件的方式。

- Record Rewrite: 测试写与覆盖写一个文件中的特定块的性能。

  如果某个特定块足够小（比CPU数据缓存小），测出来的性能将会非常高。

- Strided Read: 测试跳跃读一个文件的性能。

  一一定间隔来读取文件，例如：在0偏移量处读4Kbytes，然后间隔200Kbytes,读4Kbytes，再间隔200Kbytes，如此反复。文件中使用了数据结构并且访问这个数据结构的特定区域的应用程序常常这样做。

- Fwrite: 测试调用库函数fwrite()来写文件的性能。

  一个执行缓存与阻塞写操作的库例程，缓存在用户空间之内。如果一个应用程序想要写很小的传输块，fwrite()函数中的缓存与阻塞I/O功能能通过减少实际操作系统调用并在操作系统调用时增加传输块的大小来增强应用程序的性能。

- Fread:测试调用库函数fread()来读文件的性能。

  一个执行缓存与阻塞读操作的库例程，缓存在用户空间之内。如果一个应用程序想要读很小的传输块，fwrite()函数中的缓存与阻塞I/O功能能通过减少实际操作系统调用并在操作系统调用时增加传输块的大小来增强应用程序的性能。

- Freread: 与上面的fread 类似，除了在这个测试中被读文件是最近才刚被读过。这将导致更高的性能，因为操作系统缓存了文件数据。

# 其他测试工具

- hparm
- gnome-disks的测试工具