#!/bin/sh
log=./proxy.log
if [[ ! -e $log ]]
then
    touch $log
fi
if [[ $(stat -c %s $log) -gt 10000 ]]
then
    echo "" > $log
fi
#========远程转发======
#远程主机地址 (在该主机上面的sshd_config中将GatewayPorts 设为yes)
remoteHost=

#远程主机sshd端口
remotePort=22

#远程主机的转发端口(远程主机非root用户只能使用1024以上端口)
proxyPort=

#远程主机登录用户名
remoteUser=

#本地主机地址
localHost=localhost

#本地主机sshd端口
localPort=22

#本地主机用户名
localUser=$(whoami)

#本地用户私钥（对应上传到远程主机的公钥）
key="~/.ssh/id_rsa"

#ssh选项（用以保持连接）
options='-o TCPKeepAlive=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o ControlMaster=auto -o ControlPath=~/.ssh/%r@%h:%p -o ControlPersist=yes -o ControlPersist=600 -o StrictHostKeyChecking=no'

#======转发前检查

#查找进程中是否已经存在指定进程
tunnelstate=$(ps aux|grep $proxyPort:$localHost:$localPort|grep -v grep)
if [[ -n $tunnelstate ]]
then
    echo "$(date) sshproxy is running" >> $log
    exit 1
fi


#验证与远程主机通信状况
if [[ -z $remoteHost ]]
then
    echo "not found remote host"
    exit 1
fi

#networkstate=`ping -c 2 z.cn`
networkstate=$(timeout 5 curl $remoteHost:$remotePort 2>/dev/null |grep -i ssh)

if [[ -z $networkstate ]]
then
    echo "can not communicate with remote host ssh port, check remote host or ssh port"
    exit 1
fi

#检查密钥
if [[ -f $key ]]
then
    echo "not find ssh public key"
    exit 1
fi

#====ssh转发

echo "$(date) starting ssh proxy" >> $log
ssh -gfCNTR $proxyPort:$localHost:$localPort $remoteUser@$remoteHost -i $key $options -p $remotePort

##ssh参数说明
#-g 允许远程主机连接转发端口
#-f 后台执行
#-C 压缩数据
#-N 不要执行远程命令
#-R 远程转发
