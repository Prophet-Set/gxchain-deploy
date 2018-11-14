#!/bin/bash
#------------------------------------------------------
#
# Nginx install script on ubuntu
#
# @author https://wangwei.one/
# @date 2018/11/13
#------------------------------------------------------
set -e

# config nginx script home
NGINX_SCRIPT_HOME="/home/gxcchainuser/gxchain-script/nginx-script"
# config build home
BUILD_HOME="/home/gxcchainuser/compile/"

# nginx mainline version
NGINX_VERSION='1.15.6'
#defind version
OPENSSL_VERSION='1.1.1'
# https://www.modpagespeed.com/doc/release_notes
NPS_VERSION='1.13.35.2-stable'
# defind pcre version(4.4 — 8.41)
PCRE_VERSION='8.41'
# defind zlib version
ZLIB_VERSION='1.2.11'

# mix nginx name and version
MIX_NGINX_NAME='MyServer'
MIX_NGINX_VERSION='1.2.3'

NGINX_HOME="/etc/nginx/"
NGINX_GROUP="nginx"
NGINX_USER="nginx"

RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

compile(){
	
	echo "Install dependencies"
	apt-get update && apt-get upgrade -y
	sudo apt autoremove
	
	# Install dependencies
	# 
	# * checkinstall: package the .deb
	# * libpcre3, libpcre3-dev: required for HTTP rewrite module
	# * zlib1g zlib1g-dbg zlib1g-dev: required for HTTP gzip module
	# apt-get install openssl libssl-dev libperl-dev libpcre3 libpcre3-dev zlib1g zlib1g-dbg zlib1g-dev libxslt1-dev libxml2-dev
	apt-get install checkinstall build-essential libgeoip-dev uuid-dev libgd2-xpm-dev libgoogle-perftools-dev

	# create build home
	if [ ! -d ${BUILD_HOME} ]; then
	   echo "create build home"
	   mkdir -p ${BUILD_HOME}
	fi

	cd ${BUILD_HOME}

	# download pcre
	echo "Delete exist pcre file"
	rm -rf ${BUILD_HOME}/pcre-*
	echo "Download pcre-$PCRE_VERSION"
	wget --no-check-certificate https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz && tar -xzvf pcre-$PCRE_VERSION.tar.gz

	# zlib version 1.1.3 - 1.2.11
	rm -rf ${BUILD_HOME}/zlib-$ZLIB_VERSION*
	echo "Download zlib-$ZLIB_VERSION"
	wget http://www.zlib.net/zlib-$ZLIB_VERSION.tar.gz && tar -xzvf zlib-$ZLIB_VERSION.tar.gz

	# Compile against OpenSSL to enable NPN
	echo "Delete exist openssl-${OPENSSL_VERSION} file"
	rm -rf ${BUILD_HOME}/$*openssl-${OPENSSL_VERSION}*
	echo "Download openssl-${OPENSSL_VERSION}"
	wget http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz

	# Download the Cache Purge module
	echo "Delete exist ngx_cache_purge"
	rm -rf ${BUILD_HOME}/*ngx_cache_purge*
	echo "Download ngx_cache_purge"
	git clone https://github.com/FRiCKLE/ngx_cache_purge.git

	# Download PageSpeed
	# https://www.modpagespeed.com/doc/build_ngx_pagespeed_from_source
	echo "Delete pagespeed ngx ${NPS_VERSION} "
	rm -rf ${BUILD_HOME}/*${NPS_VERSION}*
	echo "Download pagespeed ngx ${NPS_VERSION} "
	wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
	unzip v${NPS_VERSION}.zip
	nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
	cd "$nps_dir"
	NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
	NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
	psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
	[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
	# extracts to psol/
	wget ${psol_url} && tar -xzvf $(basename ${psol_url})

	# Get the Nginx source.
	#
	# Best to get the latest mainline release. Of course, your mileage may
	# vary depending on future changes
	cd ${BUILD_HOME}
	echo "Delete exist nginx-${NGINX_VERSION} file"
	rm -rf ${BUILD_HOME}/*nginx-${NGINX_VERSION}*
	echo "Download nginx-${NGINX_VERSION} source file "
	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar -xzvf nginx-${NGINX_VERSION}.tar.gz

	# Modify nginx source code. Mix nginx info
	echo "Start modify nginx name and version info."
	# modify nginx.h to mix version
	sed -ri "s/#define\s+NGINX_VERSION\s+\"${NGINX_VERSION}\"/#define NGINX_VERSION      \"${MIX_NGINX_VERSION}\"/g;" ${BUILD_HOME}/nginx-${NGINX_VERSION}/src/core/nginx.h
	sed -ri "s/#define\s+NGINX_VER\s+\"nginx\/\" NGINX_VERSION/#define NGINX_VER          \"${MIX_NGINX_NAME}\/\" NGINX_VERSION /g;" ${BUILD_HOME}/nginx-${NGINX_VERSION}/src/core/nginx.h
	# modify ngx_http_header_filter_module.c to mix name
	sed -ri "s/static\s+u_char\s+ngx_http_server_string\[\]\s+=\s+\"Server: nginx\" CRLF;/static u_char ngx_http_server_string\[\] = \"Server: ${MIX_NGINX_NAME}\" CRLF;/g;" ${BUILD_HOME}/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c

	# Configure nginx.
	# 
	# http://nginx.org/en/docs/configure.html
	# https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-ubuntu-16-04
	# https://gist.github.com/tollmanz/8662688
	#
	# This is based on the default package in Debian. Additional flags have
	# been added:
	#
	# * --with-debug: adds helpful logs for debugging
	# * --with-openssl=$HOME/sources/openssl-1.0.1e: compile against newer version of openssl
	# * --with-http_v2_module: include the SPDY module
	cd ${BUILD_HOME}/nginx-${NGINX_VERSION}
	./configure --prefix=$NGINX_HOME \
	--sbin-path=/usr/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--modules-path=/usr/lib/nginx/modules \
	--user=$NGINX_USER \
	--group=$NGINX_GROUP \
	--build=Ubuntu \
	--with-openssl=$BUILD_HOME/openssl-${OPENSSL_VERSION} \
	--with-openssl-opt=enable-ec_nistp_64_gcc_128 \
    	--with-openssl-opt=no-nextprotoneg \
    	--with-openssl-opt=no-weak-ssl-ciphers \
    	--with-openssl-opt=no-ssl3 \
    	--with-pcre=$BUILD_HOME/pcre-$PCRE_VERSION \
    	--with-pcre-jit \
    	--with-zlib=$BUILD_HOME/zlib-$ZLIB_VERSION \
    	--with-zlib-asm=cpu \
    	--with-compat \
	--with-http_ssl_module \
	--with-http_slice_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_auth_request_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_geoip_module \
	--with-http_image_filter_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-file-aio \
	--with-threads \
	--with-http_v2_module \
	--with-google_perftools_module \
    	--with-debug \
    	--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
        --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
	--add-module=$BUILD_HOME/$nps_dir \
	--add-module=$BUILD_HOME/ngx_cache_purge

	echo -e "$GREEN Nginx configure finished ! $NO_COLOR"

	# Make the package.
	make
	echo -e "$GREEN Nginx package make finished ! $NO_COLOR"

	# Create a .deb package.
	#
	# Instead of running `make install`, create a .deb and install from there. This
	# allows you to easily uninstall the package if there are issues.
	checkinstall --install=no -y
	echo -e "$GREEN Nginx .deb package create finished ! $NO_COLOR"
	return 0
}

install(){
	# Install the package.
	dpkg -i $BUILD_HOME/nginx-$NGINX_VERSION/nginx_$NGINX_VERSION-1_amd64.deb
	echo -e "$GREEN Nginx install finished ! $NO_COLOR"
	return 0
}

uninstall(){
	# uninstall .deb package
	dpkg -l "nginx" &> /dev/null
	if [ $? = 0 ]; then
		dpkg -P nginx
	fi

	# delete user and group
	grep "$NGINX_USER" /etc/passwd &> /dev/null
	if [ $? = 0 ] ; then
	    userdel $NGINX_USER
	fi

	# rm -rf some nginx files
	rm -rf /etc/nginx
	rm -rf /usr/sbin/nginx
	rm -rf /var/log/nginx
	rm -rf /var/run/nginx*
	rm -rf /var/cache/nginx
	rm -rf /usr/lib/nginx

	echo -e "$GREEN Nginx uninstall finished ! $NO_COLOR"
	return 0
}

config(){
	# clean default config files
	if [ ! -d "$NGINX_HOME/default.d/" ]; then
		mkdir -p $NGINX_HOME/default.d/
	fi
	cp -rp $NGINX_HOME/*.default $NGINX_HOME/default.d/
	echo -e "$GREEN Nginx default config files clean finished ! $NO_COLOR"

	# remove .default suffix
	

	# config nginx
	cp -rp $NGINX_SCRIPT_HOME/nginx_conf/* $NGINX_HOME
	# set nginx file permission
	chmod -R 644 $NGINX_HOME
	chmod o+x $NGINX_HOME/html
	echo -e "$GREEN Nginx config files set finished ! $NO_COLOR"

	# config systemctl nginx.service
	chmod 644 $NGINX_SCRIPT_HOME/nginx.service 
	mv $NGINX_SCRIPT_HOME/nginx.service /lib/systemd/system/

	systemctl enable nginx

	# auto startup on server boot
	grep 'systemctl start nginx' /etc/rc.local &> /dev/null
  	if [ $? != 0 ] ; then
      	   sed -i '/exit\s0/d' /etc/rc.local
           echo -e "systemctl start nginx\nexit 0" >> /etc/rc.local
	fi
	echo -e "$GREEN Nginx startup service config finished ! $NO_COLOR"
        return 0
}

certbot(){
	# install certbot
	# https://medium.com/@jgefroh/a-guide-to-using-nginx-for-static-websites-d96a9d034940
	apt-get update
	apt-get install software-properties-common
	add-apt-repository ppa:certbot/certbot
	apt-get update
	apt-get install python-certbot-nginx 

	# crate certificate for nginx
	certbot --nginx certonly
	
	# auto renew config
	# certbot renew --dry-run

	return 0
}

case $1 in
compile)
  compile
;;
install)
  install
;;
uninstall)
  uninstall
;;  
config)
  config
;;
certbot)
  certbot
;;
esac
exit 0








