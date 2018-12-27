本文所述安装环境为CentOS7.x，使用oracle mysql community rpm包安装于默认位置。

# 基本安装

根据需求安装各个rpm包，mysql community rpm bundles（5.7及以上版本）含有以下软件包（带*为必须安装）：

- mysql-community-client（*客户端程序和工具）
- mysql-community-server（*服务器程序和工具）
- mysql-community-libs（*LIB库）
- mysql-community-libs-compat（*LIB共享兼容库）
- mysql-community-common（*公共文件）
- mysql-community-devel（开发MySQL必备的头文件和库）
- mysql-community-embedded（嵌入式库）
- mysql-community-embedded-compat（嵌入式共享兼容库）
- mysql-community-embedded-dev（嵌入式开发库）
- mysql-community-minimal-debuginfo（最小安装调式信息库）
- mysql-community-server-minimal（最小安装服务器程序和工具）
- mysql-community-test（测试套件）

其中server-minimal是server的最小化版，二者中安装一个即可。

示例：

```shell
yum install mysql*{server,client,common,libs}*.rpm
systemctl start mysqld  #注意mysql5.6及以下的服务名为mysql而非mysqld
```

mysql5.7+为root用户生成了随机密码，位于`err_log`中（默认在`/var/log/mysqld.log`）：

```shell
grep --color password /var/log/mysqld.log
```

可从日志中看到类似该行字样`A temporary password is generated for root@localhost:`其行末便是root密码。

建议安装后执行`mysql_secure_installation`进行初始配置。其会询问用户作出一些**安全性**相关的设置建议，主要流程：

- 是否设置root密码
- 是否禁止远程登录
- 是否删除匿名帐号
- 是否删除测试数据库test
- 是否立即使以上操作生效

# 常用配置

根据需要修改配置文件。以rpm安装后，配置文件一般有两处：`/usr/my.cnf`和`/etc/my.cnf`。

`/etc/my.cnf`存在时，`/usr/my.cnf`无效，以下所述`my.cnf`配置文件均指`/etc/my.cnf`。

基本配置示例：

```shell
[mysqld]
user=mysql  #mysql执行用户
datadir=/data/mysql  #数据存放位置
socket=/data/mysql.sock  #套接字（一般在datadir下）

log-error=/var/log/mysqld.log  #日志
pid-file=/var/run/mysqld/mysqld.pid  #进程标识号文件

default-storage-engine = INNODB
# 编码部分（设置为utf8）
character-set-server = utf8
#collation-server = utf8_general_ci  #不区分大小写
#collation-server = utf8_bin  #区分大小写
collation-server = utf8_unicode_ci  #比 utf8_general_ci 更准确

[client]
default-character-set = utf8  #客户端默认编码
```

## 忘记root用户密码

忘记数据库root用户密码的情况下修改密码。

1. 在`my.cnf`的mysqld下添加`skip-grant-tables`

   ```shell
   [mysqld]
   skip-grant-tables
   #其他内容略
   ```

2. 重启mysql服务

3. 使用`mysql -uroot -p`登录mysql命令行

4. SQL语句设置密码，这里示例将root密码设置为`root`

   ```mysql
   use mysql
   update mysql.user set authentication_string=password('root') where user='root';
   flush privileges;  
   ```

   注意：mysql5.6以下版本设置密码使用`update user set password =password('root') where user='root';`。

5. 去掉`my.cnf`中的`skip-grant-tables`，重启mysql服务，以`mysql -uroot -proot`即可登录mysql。

## 修改密码强度策略

MySQL5.6.6版本之后增加了密码强度验证插件validate_password，默认策略较为严格，要求密码满足三种不同类型的字符（例如数字+字母+符号）。

通过修改validate_password_policy的值降低密码强度要求，例如修改为最小3个字符的任意字符密码：

```sql
 select @@validate_password_policy;
 set global validate_password_policy=0;
 set global validate_password_mixed_case_count=0;
 set global validate_password_number_count=3;
 set global validate_password_special_char_count=0;
 set global validate_password_length=3;
 SHOW VARIABLES LIKE 'validate_password%';
 flush privileges;
 SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123');
```

