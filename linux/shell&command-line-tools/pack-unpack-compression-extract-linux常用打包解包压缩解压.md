[TOC]

- 跨平台压缩推荐使用7z或zip（注意使用UTF-8格式！）
- tar打包压缩推荐配合xz压缩，xz具有较高的压缩率。

以下示例命令中test指某个文件或者文件夹

# 常见打包和压缩格式

## tar

### tar打包解包

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

- -f <归档文件>或--file=<归档文件>：指定归档文件（即要打包/压缩成的文件）；

- -r：添加文件到已经压缩的文件；

- -p或--same-permissions：用原来的文件权限还原文件；

- -A或--catenate：新增文件到以存在的备份文件；

- -u：添加发生变更的文件到已经存在的压缩文件；

- -k：保留原有文件不覆盖；

- -w：确认压缩文件的正确性；

- -C <目录>：这个选项用在解压缩时指定解压到特定目录；

### tar+xz或gz或bz2合用

tar添加以下参数，在打包tar后压缩成xz、bz2、gz等格式，或在解压缩xz、bz2、gz后再解tar包。

- -J ：支持xz
- -j：支持bz2
- -z：支持gz

```shell
tar xJvf test.tar.xz  #解压xz后解包tar
tar cJvf tets.tar.xz  #打包tar后压缩为xz格式
```

### 加密打包/解密解包

与某些加密工具组合使用，例如gpg（gnupg）：

```shell
tar cJvf test.tar.xz test
#加密 -c使用对称加密  生成以.gpg结尾的文件 不能对目录加密
gpg -c test.tar.xz  #会提示输入密码
#解密 -o指定生成的解密文件，-d指定被解密的文件（该选项为默认选项可不写）。
gpg -o test.tar.xz -d test.tar.xz.gpg
```

## .gz

参照上文，可配合tar使用。

```shell
#gzip或gnuzip
gzip test.gz  #解压
gzip -d test.gz  #解压
gzip test  #压缩
```

## .bz2

参照上文，可配合tar使用。

```shell
#使用bzip2或bunzip2
bzip2 -z test  #压缩
bzip2 -d test.bz2  #解压
```

## .xz

- `-k`或`--keep`  保存源文件（默认是压缩后删除原来的文件） 
- `-n`  压缩率n （取值0-9，默认6）
- `-T n`或`--threads=n`  使用n个线程压缩（多线程需要xz版本5.2及以上  默认单线程）
- `-e`或`--extreme`  尝试通过使用更多的CPU时间来提高压缩比
- `l`或`--list`  查看.xz文件中的信息
- `-z`或`--compress`  强制压缩
- `d`或`--decompress`  强制解压
- `-t`或`--test`  压缩测试

参照上文，可配合tar使用。

```shell
xz -8ekv-T 9 test  #压缩
xz -d test.xz  #解压
```

## .zip

压缩工具：zip

解压工具：unzip

- `-P`  指定压缩或解压密码
- `-l`  列出压缩包中文件（不解压）

unzip-iconv，为unzip增加了转码补丁，可在解压缩时使用`-O`参数可指定编码格式。

```shell
zip test.zip test  #打包
unzip test.zip  #解包
#指定编码格式(如gbk)避免乱码 需要安装unzip-iconv
unzip -O gbk test.zip
zip -P 123 files.zip files
unzip -P 123 files.zip
```

## .7z

工具p7zip

```shell
7za a  test.7z test  #压缩
7za x test.7z  #解压
```

## .rar

压缩工具：rar

解压工具：unrar

```shell
rar a test.rar test  #压缩
unrar test.rar  #解压
```

- `-x`  用绝对路径解压文件
- `-e`  解压到当前路径
- `-p`  指定解压密码

分卷解压

```shell
#例如某文件压缩为 file.part1.rar   fiel.part2.rar
unrar -x file.part1.rar  #解压第一个分卷即可，其会自动合并解压所有分卷
```

# 特殊文件打包/解包和压缩/解压

## archlinux系安装包

- 解包/解压缩：tar.xz格式，参看上文[tar](#tar)。
- 打包工具：makepkg

## redhat系安装包rpm

- 解包/解压缩：

  RPM包括是使用cpio格式打包的，因此可以先转成cpio然后解压，如下所示：

  ```shell
  rpm2cpio <file.rpm> | cpio -div
  ```

- 打包rpm工具：rpmbuild

## debian系安装包deb

- 解包工具：ar

  ```shell
  ar -x <file.deb>
  tar -zxvf data.tar.gz  #解开应用文件夹
  ```

- 打包deb工具：dpkg-deb

## exe

- 解压缩：p7zip

  ```shell
  7z -x <file.exe>
  ```


