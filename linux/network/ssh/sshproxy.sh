#!/bin/sh

#========远程转发======
#远程主机地址 (在该主机上面的sshd_config中将GatewayPorts 设为yes)
remoteHost=

#远程主机登录用户名
remoteUser=

#远程主机登录端口
remotePort=22

#远程主机的转发端口
proxyPort=1998

#登录远程主机的密钥
key="~/.ssh/id_rsa"

#本地主机
localHost=localhost

#本地主机用户名
localUser=`whoami`

#本地转发端口
localPort=22

#选项 保持连接
options='-o TCPKeepAlive=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o ControlMaster=auto -o ControlPath=~/.ssh/%r@%h:%p -o ControlPersist=yes -o ControlPersist=600 -o StrictHostKeyChecking=no'

#======转发前检查
case param in

#查找进程中是否已经存在指定进程
tunnelstate=`ps aux | grep "${remotePort}:$localHost:$localPort" | grep -v grep`
if [[ $tunnelstate ]]
then
  echo "sshproxy is running"
  exit 0
fi


#验证与远程主机通信状况

if [[ -z $remoteHost ]]
then
  echo "not found remote host"
  exit 0
fi

#networkstate=`ping -c 2 z.cn`
networkstate=`timeout 5 curl $remoteHost:$remotePort |grep -i ssh`

if [[ -z $networkstate ]]
then
  echo "can not communicate with remote host ssh port, check remote host or ssh port"
  exit 0
fi

#检查密钥
if [[ -f $key ]]
then
  echo "not find ssh public key"
  exit 0
fi

#====ssh转发
if [[ -z `ps axu|grep  1998|grep ssh|grep -v grep` ]]
then
  ssh -gfCNTR ${proxyPort}:${localHost}:${localPort} ${remoteUser}@${remoteHost} -i ${key} $options -p ${remotePort}
fi
##ssh参数说明
#-g 允许远程主机连接转发端口
#-f 后台执行
#-C 压缩数据
#-N 不要执行远程命令
#-R 远程转发
