#!/bin/sh
#-----container config params-----
name=phpmyadmin  #container name
hostname=$name  #hostname
port=2222

user=`whoami`

#sql | example localhost:3306 (default port 3306 could be omitted)
sqlserver=(localhost:3306)
#------docker config params-----end

#-----functions-----
function createcontainer(){
    #creat container
    docker run -d -it --name $name --hostname $hostname -p $port:80 centos /bin/bash

    #install packages
    docker exec $name yum install -y epel-release
    docker exec $name yum install -y php php-fpm nginx phpmyadmin

    #config php
    docker cp phpmyadmin:/etc/php-fpm.d/www.conf ./
    sed -i -e "s/apache/nginx/" -e "s/^\;env/env/" www.conf
    docker cp www.conf phpmyadmin:/etc/php-fpm.d/

    #config nginx
    echo '
location ~ \.php$ {
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
    }' > php.conf

    docker cp phpmyadmin:/etc/nginx/nginx.conf ./
    sed -i -e "/root/i $phpconfig" nginx.conf
    docker cp nginx.conf phpmyadmin:/etc/nginx/nginx.conf
    docker cp php.conf phpmyadmin:/etc/nginx/default.d/

    #config phpmyadmin
    docker exec phpmyadmin ln -s /usr/share/phpMyAdmin /usr/share/nginx/html/
}
#-----functions-----end

#########
# check docker
if [ -n `which docker |grep 'no docker'` ]
then
    echo "please install docker first"
    exit
fi

echo "please use sudo or root permission"
sudo -S date

# check docker daemon
if [ -z `pgrep docker` ]
then
    sudo systemctl start docker
fi

#check centos images
if [ -z `docker images |grep centos` ]
then
    sudo docker pull centos
fi

#Check if the container exists
if [ -n `docker ps |grep phpmyadmin` ]
then
    echo 'phpmyadmin container is already exists'
    docker exec -it phpmyadmin /bin/bash
elif [ -n `docker ps -a |grep phpmyadmin` ]
then
    docker start phpmyadmin
    docker exec -it phpmyadmin /bin/bash
else
    createcontainer
fi

#connect sql sqlserver
docker cp phpmyadmin:/etc/phpMyAdmin/config.inc.php ./
#sed -i 's/\(AllowArbitraryServer*\)false/\1true/' config.inc.php;

sed -i //todo加上一行host设置

doker cp config.inc.php phpmyadmin:/etc/phpMyAdmin/

#start
docker exec phpmyadmin nginx php-fpm

echo -e "open http://localhost:$port"
