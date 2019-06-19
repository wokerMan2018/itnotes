#!/bin/bash
#===proxy log 日志
log=./proxy.log
touch $log

#log file size control 日志文件大小控制 10000Bytes
if [[ $(stat -c %s $log) -gt 10000 ]]; then
    tmp_log=$(mktemp)
    tail -n 20 $log >$tmp_log
    cat $tmp_log >$log
fi

#log timestamp
echo "======$(date)======" >>$log

#===cron task 周期任务
user=$(whoami)
#script is this script file path
[[ $(echo $0 | grep $PWD) ]] && script=$0 || script=$PWD/$0
chmod +x $script
if [[ ! $(crontab -l | grep $script) ]]; then
    cronlist=$(mktemp)
    echo -e "1 * * * * $script\n@reboot $script" >>$cronlist
    crontab $cronlist
fi

#=====Remote Port Forward======远程主机转发
#remote host addr 远程主机
#the host as a proxy server 这个主机作为代理服务器
remoteHost= #IP or URL

#remote host sshd port 远程主机的sshd端口
remotePort=22

#user on remote host 远程主机上的用户
remoteUser=proxyuser

#remote host forward port 远程主机的转发端口
#common users could only use ports above 1024 普通用户只能使用1024以上端口
proxyPort=2001

#local host (this host) 本地主机（当前主机）
#the host which excutes the forwarding command 这个主机是执行转发命令的主机
localHost=localhost

#local host sshd port 地主机sshd端口
localPort=22

#local host user 本地主机用户名
localUser=$(whoami)

#ssh private key for above user 本地用户（上面那个localUser用户）的私钥（对应上传到远程主机的公钥）
key="~/.ssh/id_rsa"

#ssh options ssh选项（用以保持连接）
options='-o TCPKeepAlive=yes -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -o ControlMaster=auto -o ControlPath=~/.ssh/%r@%h:%p -o ControlPersist=yes -o StrictHostKeyChecking=no'

#======checking 转发前检查

#check ssh process 查找进程中是否已经存在指定的ssh转发进程
forwarding_process_info=$(ps -ef | grep $proxyPort:$localHost:$localPort | grep -v grep)

[[ -n $forwarding_process_info ]] && forwarding_pid=$(echo $forwarding_process_info | awk '{print $2}')

#If the process already exists 如果转发进程已经存在
if [[ -n $forwarding_process_info ]]; then
    #check the forwarding port 检查转发端口连通情况
    timeout 5 curl --silent $remoteHost:$proxyPort
    if [[ $? -eq 0 ]]; then
        echo "sshproxy is running" >>$log
        exit 1
    else
        kill -9 $forwarding_pid
    fi
fi

#check remote host 验证与远程主机
[[ -z $remoteHost ]] && echo "Missing remote host" >>$log && exit 1

#check ssh key file 检查密钥文件
[[ -f $key ]] && echo "Can not find ssh key file" >>$log && exit 1

#ssh forwarding 转发
echo "starting ssh proxy" >>$log
ssh -gfCNTR $proxyPort:$localHost:$localPort $remoteUser@$remoteHost -i $key -p $remotePort $options

##ssh参数说明
#-g 允许远程主机连接转发端口
#-f 后台执行
#-C 压缩数据
#-N 不要执行远程命令
#-R 远程转发
