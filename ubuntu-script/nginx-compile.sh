#!/bin/bash
########################################################
#
# Nginx build script on ubuntu
#
########################################################

BUILD_HOME="/mydata/source/"
#defind version
OPENSSL_VERSION='1.1.1'
# http://nginx.org/en/download.html
NGINX_VERSION='1.14.1'
# https://www.modpagespeed.com/doc/release_notes
NPS_VERSION='1.13.35.1-beta'
# mix nginx name and version
MIX_NGINX_NAME='Apache'
MIX_NGINX_VERSION='2.4.37'

# Install dependencies
# 
# * checkinstall: package the .deb
# * libpcre3, libpcre3-dev: required for HTTP rewrite module
# * zlib1g zlib1g-dbg zlib1g-dev: required for HTTP gzip module
echo "Install dependencies"
apt-get install checkinstall libpcre3 libpcre3-dev zlib1g zlib1g-dbg zlib1g-dev

# create build home
if [[ ! -d ${BUILD_HOME} ]]; then
   echo "create build home"
   mkdir -p ${BUILD_HOME}
fi

# Compile against OpenSSL to enable NPN
cd ${BUILD_HOME}
echo "Delete exist openssl-${OPENSSL_VERSION} file"
rm -rf ${BUILD_HOME}/$*openssl-${OPENSSL_VERSION}*
echo "Download openssl-${OPENSSL_VERSION}"
wget http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz

# Download the Cache Purge module
cd ${BUILD_HOME}
echo "Delete exist ngx_cache_purge"
rm -rf ${BUILD_HOME}/*ngx_cache_purge*
echo "Download ngx_cache_purge"
git clone https://github.com/FRiCKLE/ngx_cache_purge.git

# Download PageSpeed
cd ${BUILD_HOME}
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
wget ${psol_url}
# extracts to psol/
tar -xzvf $(basename ${psol_url})

# Get the Nginx source.
#
# Best to get the latest mainline release. Of course, your mileage may
# vary depending on future changes
cd ${BUILD_HOME}
echo "Delete exist nginx-${NGINX_VERSION} file"
rm -rf ${BUILD_HOME}/*nginx-${NGINX_VERSION}*
echo "Download nginx-${NGINX_VERSION} source file "
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar zxf nginx-${NGINX_VERSION}.tar.gz

# Modify nginx source code. Mix nginx info
# modify nginx.h
sed -ri 's/#define NGINX_VERSION      "${NGINX_VERSION}"/ ${MIX_NGINX_VERSION} /g;' $BUILD_HOME/nginx-${NGINX_VERSION}/src/core/nginx.h
sed -ri 's/#define NGINX_VER          "nginx\\/" NGINX_VERSION/ *** /g;' $BUILD_HOME/nginx-${NGINX_VERSION}/src/core/nginx.h
# modify ngx_http_header_filter_module.c
sed -ri 's/static u_char ngx_http_server_string[] = "Server: nginx" CRLF;/ *** /g;' $BUILD_HOME/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c
sed -ri 's/static u_char ngx_http_server_full_string[] = "Server: " NGINX_VER CRLF;/ *** /g;' $BUILD_HOME/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c

# Configure nginx.
#
# This is based on the default package in Debian. Additional flags have
# been added:
#
# * --with-debug: adds helpful logs for debugging
# * --with-openssl=$HOME/sources/openssl-1.0.1e: compile against newer version
#   of openssl
# * --with-http_spdy_module: include the SPDY module
cd ${BUILD_HOME}/nginx-${NGINX_VERSION}
./configure --prefix=/etc/nginx \
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
--user=www-data \
--group=www-data \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-http_spdy_module \
--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
--with-ipv6 \
--with-debug \
--with-openssl=$BUILD_HOME/openssl-${OPENSSL_VERSION} \
--add-module=$BUILD_HOME/$nps_dir \
--add-module=$BUILD_HOME/ngx_cache_purge

# Make the package.
make

# Create a .deb package.
#
# Instead of running `make install`, create a .deb and install from there. This
# allows you to easily uninstall the package if there are issues.
checkinstall --install=no -y

# Install the package.
dpkg -i nginx_$NGINX_VERSION-1_amd64.deb


# https://www.nginx.com/blog/mitigating-ddos-attacks-with-nginx-and-nginx-plus/
# 










