# 主要日志文件

## systemd日志

日志保存在/var/log/journal/目录下，使用`journalctl`命令查看

## 用户记录文件

以二进制保存，需要使用特定工具查看。

- /var/run/utmp  记录当前打开的会话

  `who`和`w`查看当前有谁登录以及他们正在做什么

  `uptime`查看系统启动时间。

- /var/log/wtmp  记录系统的连接历史

  `last`查看最后登录的用户的列表。

- /var/log/btmp  记录失败的登录尝试

  `lastb`查看后失败的登录尝试的列表。

- /var/log/lastlog  记录所有用户最近一次登录情况



# 日志管理

## logrotate 日志轮转

