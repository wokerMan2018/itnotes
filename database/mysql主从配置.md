基于日志中sql命令的复制和执行

安装时默认log地址可能导致报错 修改/etc/my.cnf中mysqld-safe的日志路径

主从服务器安装数据库版本最好一致
主从服务器数据库保持一致

如果使用rpm安装　即使修改了默认sock位置　它还是会读取/var/lib/mysql/mysql.sock　不修改或者软链接新sock到原来的位置



```
NaxYJOByz@kqUvop84cEz&itabaj
```

注意selinux和防火墙

示例：
主40.50.0.36 从40.50.0.37 40.50.0.38

数据库放置位置/data/mysql/

用户root 密码mysql 测试数据库hellodb

# 基本配置



1.安装mysql（可能需要依赖包autoconf）
2.启用mysql服务 设置开机自启动 检查mysql情况

mysql_securite_installation初始设置

3.停止服务，配置/etc/my.cnf

```shell
[mysqld]
user=mysql  #执行用户
datadir = /data/mysql  #mysql数据存放位置
socket = /data/mysql/mysql.sock  #socket位置

#utf配置
character-set-server = utf8
collation-server = utf8_unicode_ci

[client]
default-character-set = utf8
```

移动位置

```shell
cp -av /var/lib/mysql　/data/
```

启动数据库并检查情况

## 主从配置

创建专门用户同步的用户sync密码dbsync_@sc_mysql

```sql
create user 'sync'@'%' identified by 'dbsync_@sc_mysql';
create database db_trawe character set utf8;
grant all privileges on *.* to 'sync'@'%' identified by 'dbsync_@sc_mysql';
flush privileges;
```





停止所有主机mysql服务

## 主服务器

配置/etc/my.cnf

```shell
[mysqld]
user=mysql  #执行用户
datadir = /data/mysql  #mysql数据存放位置
socket = /data/mysql/mysql.sock  #socket位置

###主服务器配置
server-id=1  #该值唯一，不能和其他从服务器的id一致

log_bin=mysql-bin #开启二进制日志
expire_logs_days = 233  #日志保留时间
sync_binlog = 5  # binlog的写入频率  该参数性能消耗很大，但可减小MySQL崩溃造成的损失

binlog_format = mixed # 日志格式，建议mixed
#集中日志格式如下：
# statement 保存SQL语句  （默认）
# row 保存影响记录数据
# mixed 前面两种的结合


##同步数据库列表
#不同步以下数据库（一行一个）
binlog-ignore-db = mysql  
binlog-ignore-db = test  
binlog-ignore-db = information_schema  

#只同步以下数据库（一行一个）--除此之外，其他不同步 ，因此可以不再指定不同步的数据库
binlog-do-db = hellodb

#utf配置
character-set-server = utf8
collation-server = utf8_unicode_ci

[client]
default-character-set = utf8
```

添加从服务器

```sql
show variables like "log_bin";
show master status;
grant replication slave,file on *.* to 'sync'@'40.50.0.37' identified by 'dbsync_@sc_mysql';
grant replication slave,file on *.* to 'sync'@'40.50.0.38' identified by 'dbsync_@sc_mysql';
flush privileges;
select user,host,password  from mysql.user;
```

其他常用命令

flush logs; 

reset master;

reset slave all;

## 从服务器

修改/etc/my.cnf

```shell
[mysqld]
user=mysql  #执行用户
datadir = /data/mysql  #mysql数据存放位置
socket = /data/mysql/mysql.sock  #socket位置

###从服务器配置
server-id=2  #该值唯一，不能和其他从服务器的id一致

#utf配置
character-set-server = utf8
collation-server = utf8_unicode_ci

[client]
default-character-set = utf8
```

添加主服务器

```sql
change master to master_host='40.50.0.36', 
master_port=3306, master_user='sync', 
master_password='dbsync_@sc_mysql',
master_log_file='mysql-bin.000001', 
master_log_pos=120; 
start slave;
show slave status\G;
```

注意：

- `master_log_file`和`master_log_pos`的值主服务器上`show master status`中的一致。
- `show slave status\G;`显示信息中，Slave_IO_Running和Slave_SQL_Running都为YES的时候就表示主从同步设置成功，

其他常用命令

stop slave;

reset slave;



**如果主服务器已经存在应用数据，则在进行主从复制时，需要做以下处理：**

```sql
flush tables with read lock;
show master status;

```

(3)复制数据文件
 将主服务器的数据文件（整个/opt/mysql/data目录）复制到从服务器，建议通过tar归档压缩后再传到从服务器解压。

(4)取消主数据库锁定
 mysql> UNLOCK TABLES;



## 验证主从复制

1. 主服务器的数据库db_t并rawe插入一些内容：

   ```sql
   use db_trawe;
   create table use db_trawe(id int(3),name char(10));
   insert into use db_trawe values(001,'哈哈哈哈');
   ```

2. 在从服务器上查看效果

   ```sql
   show databases;
   ```

## 主从复制错误

MySQL在主从复制的时候经常遇到错误而导致Slave复制中断，（例如删除一个在slave不存在的数据库）这个时候就需要人工干涉，来跳过这个错误，才能使Slave端的复制，得以继续进行；



跳过错误的方法：

```sql
STOP SLAVE;
SET GLOBAL SQL_SLAVE_SKIP_COUNTER=1;
SHOW GLOBAL VARIABLES LIKE 'SQL_SLAVE_SKIP_COUNTER'; 
start slave;
```

## 读写分离

需要加入第三方的调度器服务器，安装mysql-proxy，其作用是分配读操作到从服务器，写操作到主服务器。

##切换

1.show processlist\G 。查看从库同步状态，确保realylog更新完毕。 
2.查看从库的master.info。查看从库更新的情况，选择更新最近的选择作为主库。 
3.从库停掉slave同步. 
stop slave;停止slave同步 
retset master;设置为master 
4.检查是否开启了log-bin参数，如存在log-slave-updates ,read-only等参数需要注释。 
5.重启。 
6.如有其他从库 
先停止stop slave; 
change master to master_host=’IP’; 
start slave; 

show slave status\G