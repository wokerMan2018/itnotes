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
   sudo chown postgres:postgres /var/lib/postgres
   sudo su - postgres -c "initdb --locale $lang  -D  '/var/lib/postgres/data'"
   ```

   初始化命令用法参看`initdb --help`。

3. 启动`postgresql`服务

   如果是linux中使用systemd管理服务，则：

   ```shell
   systemctl start postgresql
   systemctl enable postgresql
   ```

   ---

   不建议使用initdb初始化后提示的`pg_ctl -D`命令启动服务，如果要使用该命令启动服务，则执行

   ```shell
    sudo su - postgres -c  "pg_ctl -D /var/lib/postgres/data -l logfile start"
   ```

   如果`pg_ctl `启动报错，根据`/var/lib/postgres/logfile`信息解决。如果提示类似

   > could not create lock file/run/postgresql/...

   创建该目录，授权给postgres用户，再重新启动即可：

   ```shell
   mkdir -p /run/postgresql/
   chown postgres:postgres /run/postgresql
   ```

   ---

   ## 更改默认数据库目录

   *nix中安装postgres后，其默认目录一般是`/var/lib/pgsql/data`（或`/var/lib/postgres/data`），可根据需求修改位置。

   **不要使用软链接将新数据目录链接到默认的位置，其并会正常工作。**

   示例迁移默认的`/var/lib/postgres/data`到`/home/pg/data`：

   1. 创建目标目录

      ```shell
      mkdir -p /home/pg/data
      chown -R postgres:postgrew /home/pg
      ```

   2. 停止postgresql服务

      ```shell
      systemctl stop postgresql
      ```

   3. 移动数据

      ```shell
      mv /var/lib/postgres/data/*   /home/pg/data
      ```

      如果原来的`/var/lib/postgres/data/`并没有重要数据，只是新建一个位置存放数据，可以不移动内容，直接初始化新的数据目录即可：

      ```shell
      lang=en_US.UTF-8
      sudo su - postgres -c "initdb --locale $lang  -D  '/home/pg/data'"
      ```

   4. 编辑postgresql的systemd units 文件（一般位于`/usr/lib/systemd/system`）

      修改`Environment`和`PIDFile`

      ```shell
      [Service]
      Environment=PGROOT=/home/postgres
      PIDFile=/home/postgres/data/postmaster.pid
      #如果要将/home 目录用作默认目录或表空间，需要添加：
      ProtectHome=false
      ```

## 配置文件

配置文件位于初始化时指定的目录下的data文件夹中，常用的配置文件为：

- `postgresql.conf`  主配置文件

  - 更改服务监听地址

    安装完成后，postgres服务默认只允许本地访问。

    示例，监听所有地址，修改：

    ```shell
    listen_addresses = '*'
    ```

- `pg_hba.conf`  数据库访问配置文件

  修改客户端登录验证，postgreSQL默认只允许本机连接，认证方式为ident，修改：

  ```shell
  #TYPE  DATABASE        USER            ADDRESS                 METHOD
  host           all                      all             127.0.0.1/24              md5
  ```

  *提示：initdb方式初始化时为指定`-A`参数，则会自动为本地连接启动 "trust" 认证。*

  注意：**pg_hba.conf 文件的更改对当前连接不影响，仅影响更改配置之后的新的连接。**

  修改后可使用`pg_ctl reload -D /var/lib/pgsql/` 重载数据库。

  `DATABASE`/`USER`值为`all`时表示所有数据库/用户。

  METHOD取值：

  - `reject`  拒绝

  - `trust`  信任

  - `md5`  双重MD5加密口令

  - `ident`  服务器鉴别认证

    通过联系客户端的 ident 服务器获取客户端的操作系统名，并且检查它是否匹配被请求的数据库用户名，只能在 TCIP/IP 连接上使用。

    **当为本地连接指定该认证方式时，将用 `peer` 认证来替代。**

  - `peer`  对等认证

    从操作系统获得客户端的操作系统用户，并且检查它是否匹配被请求的数据库用户名，只对本地连接可用。

  - `password`  未加密的口令

    口令是以明文形式在网络上发送的，不要在不可信的网络上使用该方式。

  - `gss`认证  只对TCP/IP 连接可用

  - `sspi`认证  只在Windows 上可用。

  - `ldap`服务器认证

  - `radius`服务器认证

  - `cert`即 SSL 客户端证书认证
  - `pam`即操作系统提供的可插入认证模块服务（PAM）认证
  - `bsd`操作系统提供的BSD 认证服务进行认证

## 创建管理角色和数据库实例

PostgreSQL安装时会自动创建名为`postgres`的系统用户。

```shell
grep postgres /etc/passwd
passwd postgres  #可以为postgres用户创建一个密码
su -l postgres
```

postgresql中的用户称为角色，默认会创建一个名为`postgres`的角色，该角色无密码。

为避免和系统＂用户＂混淆，以下均称数据库中的用户为角色。

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

*当然也可以在psql中使用SQL语句创建用户。*

## 修改数据库目录

*nix中安装postgres后，其默认目录一般是`/var/lib/pgsql/data`（或`/var/lib/postgres/data`），可根据需求修改位置。示例迁移位置为`/home/pgdata`：

```shell
pg_root=/home/postgres
data_dir=$pg_root/data
mkdir -p $data_dir
chown -R postgres:postgres $pg_root
```

修改postgres的systemd units文件中`Environment`和`PIDFile`，一般位于`/usr/lib/systemd/system`下，或名`postgresql.service`

```shell
[Service]
Environment=PGROOT=/home/postgres
PIDFile=/home/postgres/data/postmaster.pid
#如果要将/home 目录用作默认目录或表空间，需要添加：
ProtectHome=false
```



# psql命令

psql是postgreSQL的数据库管理命令，可以直接在系统shell下执行psql命令，也可以先执行`psql`进入其交互式命令行环境执行相关命令。

以下以`\`开始的均为进入`psql`环境后执行的命令。

## 角色和数据库常用命令

- 重置当前登录角色的密码：

  ```shell
  \password
  ```

- 修改指定角色的密码

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