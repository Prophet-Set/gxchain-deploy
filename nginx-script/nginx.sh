#!/bin/bash
#------------------------------------------------------
#
# Nginx install script on ubuntu
#
# @author https://wangwei.one/
# @date 2018/11/13
#------------------------------------------------------

NGINX_SCRIPT_HOME="/home/gxcchainuser/gxchain-script/nginx-script/"

NGINX_HOME="/etc/nginx/"
NGINX_GROUP="nginx"
NGINX_USER="nginx"

GREEN="\033[0;32m"
NO_COLOR="\033[0m"

compile(){
	chmod +x $NGINX_SCRIPT_HOME/nginx-compile.sh
	sudo /bin/sh $NGINX_SCRIPT_HOME/nginx-compile.sh
}

install(){
	dpkg -i $NGINX_SCRIPT_HOME/release/nginx_1.14.1-1_amd64.deb
}

uninstall(){
	dpkg -P nginx
}

config(){
	# create nginx user and group
	# create $NGINX_GROUP if not exists  
	egrep "^$NGINX_GROUP" /etc/group >& /dev/null  
	if [[ $? -ne 0 ]]; then
		groupadd $NGINX_GROUP
	fi
	# create $NGINX_USER if not exists  
	egrep "^$NGINX_USER" /etc/passwd >& /dev/null 
	if [[ $? -ne 0 ]]; then
	    useradd -s /bin/false -g $NGINX_GROUP -M $NGINX_USER
	fi 
	echo -e "$GREEN Nginx user and group create finished ! $NO_COLOR"

	# clean default config files
	if [[ ! -d "$NGINX_HOME/default.d/" ]]; then
		mkdir -p $NGINX_HOME/default.d/
	fi
	mv $NGINX_HOME/*.default $NGINX_HOME/default.d/
	mv $NGINX_HOME/nginx.conf $NGINX_HOME/default.d/
	echo -e "$GREEN Nginx default config files clean finished ! $NO_COLOR"

	# config nginx
	mv $NGINX_SCRIPT_HOME/nginx_conf/* $NGINX_HOME
	# set nginx file permission
	chmod -R 644 $NGINX_HOME
	chmod o+x $NGINX_HOME/html
	echo -e "$GREEN Nginx config files set finished ! $NO_COLOR"

	# config systemctl nginx.service
	chmod 644 $NGINX_SCRIPT_HOME/nginx.service 
	mv $NGINX_SCRIPT_HOME/nginx.service /lib/systemd/system/

	# auto startup on server boot
	grep 'systemctl start nginx' /etc/rc.local &> /dev/null
  	if [ $? != 0 ] ; then
      sed -i '/exit\s0/d' /etc/rc.local
      echo -e "systemctl start nginx\nexit 0" >> /etc/rc.local
    fi
    echo -e "$GREEN Nginx startup service add finished ! $NO_COLOR"
}

certbot(){

	# install certbot
	apt-get update
	apt-get install software-properties-common
	add-apt-repository ppa:certbot/certbot
	apt-get update
	apt-get install python-certbot-nginx 

	# crate certificate for nginx
	# certbot --nginx
	
	# auto renew config
	# certbot renew --dry-run
}








