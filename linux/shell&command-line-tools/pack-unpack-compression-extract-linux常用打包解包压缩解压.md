[TOC]

- 跨平台压缩推荐使用7z或zip（注意使用UTF-8格式！）
- tar打包压缩推荐配合xz（即最后制成.tar.xz文件），xz压缩率好，大多数linux都带有该工具。

以下示例命令中test指某个文件或者文件夹

# tar

tar打包解包

```shell
#仅查看内容
tar -tf file.tar[.xz/gz.bz]
#打包
tar -cvf test.tar test
#解包
tar -xvf test.tar test
```

常用参数：

- -c或--create：建立新的备份文件；

- -v或--verbose：显示指令执行过程；

- -x或--extract或--get：从备份文件中还原文件；

- -f<备份文件>或--file=<备份文件>：指定备份文件；

- -r：添加文件到已经压缩的文件；

- -p或--same-permissions：用原来的文件权限还原文件；

- -A或--catenate：新增文件到以存在的备份文件；

- -u：添加发生变更的文件到已经存在的压缩文件；

- -k：保留原有文件不覆盖；

- -w：确认压缩文件的正确性；

- -C <目录>：这个选项用在解压缩时指定解压到特定目录；


打包压缩/解压缩并解包：tar可加压缩参数在打包后压缩成xz、bz2和gz等格式。

- -J ：支持xz压缩
- -j：支持bz2压缩
- -z：支持gz压缩

```shell
tar xJvf test.tar.xz
tar cJvf tets.tar 
```

# .gz

```shell
#gzip或gnuzip
gzip test.gz  #解压
gzip -d test.gz  #解压
gzip test  #压缩
```

# .bz2

```shell
#使用bzip2或bunzip2
bzip2 -z test  #压缩
bzip2 -d test.bz2  #解压
```

# .xz

```shell
xz -z test  #压缩
xz -d test.xz  #解压
```

# .zip

工具zip和unzip/unzip-iconv（unzip-iconv用法同unzip，只是多了一个-O参数可指定编码格式）

```shell
zip test.zip test  #打包
unzip test.zip  #解包
#指定编码格式(如gbk)避免乱码 需要安装unzip-iconv
unzip -O gbk test.zip
```

# .7z

工具p7zip

```shell
7za a  test.7z test  #压缩
7za x test.7z  #解压
```

# .rar

工具rar和unrar

```shell
rar a test.rar test  #压缩
unrar test.rar  #解压
```
