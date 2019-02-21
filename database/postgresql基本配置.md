# 基本安装和配置

## 安装和初始化

1. 安装postgresql(或有将服务端程序单独拆分为postgresql-server)

2. 初始化数据库

   ```shell
   postgresql-setup initdb
   #其将PostgreSQL相关文件默认位于`/var/lib/pgsql/`下。
   ```

   如果没有上面的命令，可以执行以下命令初始化：

   ```shell
   lang=en_US.UTF-8
   data_dir='/var/lib/postgres/data'
   sudo chown postgres:postgres /var/lib/postgres -R
   sudo su - postgres -c "initdb --locale $lang -E UTF8 -D $data_dir"
   ```

   初始化命令用法参看`initdb --help`。

3. 启动postgres服务

   ```shell
   systemctl start postgresql
   systemctl enable postgresql
   ```

## 配置文件

配置文件位于初始化时指定的目录下。注意修改相关配置后需要重启服务。

提示：initdb方式初始化时为指定`-A`参数，则会自动为本地连接启动 "trust" 认证。

- 开启数据库服务器远程访问。

  修改`pg_hba.conf`配置文件`listen_addresses = 'localhost' `行的localhost为相应的监听地址，例如`*`为任意服务器。

  > ```shell
  > listen_addresses = '*'
  > ```

- 修改客户端登录验证

  postgreSQL默认只允许本机连接，认证方式为ident，编辑`/var/lib/pgsql/data/pg_hba.conf`相关行：

  > ```shell
  > #TYPE  DATABASE        USER            ADDRESS                 METHOD
  > host           all                      all             127.0.0.1/24              md5
  > ```

  METHOD取值：

  - `trust`  信任 免密码直接登录

  - `md5`  密码认证

  - `ident`

    > 客户端从一个ident服务器上获取一个用户名，作为连接服务器端数据库的用户的认证方式，也可能用到map映射。只支持TCP/IP。

  - `peer`

    > 安装了PostgreSQL服务端的系统，通过getpeereid()函数获取连接客户端的用户名，然后通过map映射来进行客户认证的一种认证方式，要求只能用在客户端和服务端都安装在同一台电脑上时，客户端连接服务端的认证。

## 创建管理角色和数据库实例

PostgreSQL安装时会自动创建名为`postgres`的系统用户。

```shell
grep postgres /etc/passwd
passwd postgres  #可以为postgres用户创建一个密码
su -l postgres
```

postgresql中的用户称为角色，默认会创建一个名为`postgres`的角色。

创建新角色：

```shell
createuser --interactive    #交互式创建用户
#也可以直接创建
createuser dbuser  #创建一个名为dbuser角色
```
创建数据库实例：
```shell
createdb -e -O dbuser dbname  #创建一个名为dbname的数据库实例，并将其归属于dbuser
```

# psql命令

psql是postgreSQL的数据库管理命令，可以直接在系统shell下执行psql命令，也可以先执行`psql`进入其交互式命令行环境执行相关命令。

以下以`\`开始的均为进入`psql`环境后执行的命令。

## 角色和数据库常用命令

- 重置postgres用户密码：

  ```shell
  \password
  ```

- 为新角色修改密码，先使用`psql`命令连接到PostgreSQL数据库。

  ```shell
  \password dbuser
  ```

- 其他常用postgresql命令
  - 列出所有数据库：`\l`或`psql -l`
  - 列出所有角色：`\du`
  - 退出：`\q`

## 连接数据库

postgre服务默认监听于5432端口。

```shell
psql -U dbuser -d dbname -h 127.0.0.1 -p 5432
#或
psql postgres://username:password@host:port/dbname
```

主要参数：

- `-h host`  指定连接的Postgres数据库IP地址
- `-U username`  指定连接数据库的用户名
- `-d database`  指定连接的数据库名
- `-p port`  指定数据库连接的服务端口
- `-w`  不提示用户输入密码
- `-W`  验证数据库用户密码
- `-l`  列出Postgres可用的数据库信息

### 自动连接方式

- 先导出密码变量`PGPASSWORD`，再登录时可自行认证，但不安全，一般不建议。

  ```shell
  export PGPASSWORD=123456  #假如用户dbuser的密码是123456
  psql -U dbuser -d dbname -h 127.0.0.1
  ```

- 客户端的`.pgpass`文件中提供密码

  1. 创建一个`.pgpass`文件，其中包含数据库连接的各项信息

     ```shell
     echo "127.0.0.1:5432:dbname:dbuser:123456" > ~/.pgpass
     chmod 600 ~/.pgpass
     ```

  2. 直接连接目标数据库将读取`.pgpass`文件自动认证

     ```shell
     psql -U dbuser -d dbname -h 127.0.0.1
     ```

# GUI工具

- phpPgAdmin
- pgAdmin