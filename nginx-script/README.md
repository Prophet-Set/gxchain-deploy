# Nginx优化配置

## 前言

一般说来，我们使用 `apt-get install nginx` 就可以非常简单方便地安装Nginx。

## 安装

### 脚本下载

```powershell
$ cd ~
$ git clone git@github.com:gxcdac/gxchain-script.git
$ chmod +x ~/gxchain-script/nginx-script/nginx-install.sh
```

### 参数配置

配置`nginx-install.sh`脚本参数：

```powershell
#设置Nginx脚本目录
NGINX_SCRIPT_HOME="/home/gxcchainuser/gxchain-script/nginx-script"
# 设置Nginx编译构建的目录
BUILD_HOME="/home/gxcchainuser/compile"
# 配置Nginx最新mainline版本
NGINX_VERSION='1.15.6'

# 修改Nginx源码，对Nginx的名称和版本进行混淆
MIX_NGINX_NAME='MyServer'
MIX_NGINX_VERSION='1.2.3'
```

### 编译

执行编译命令，等待编译完成，大约5min左右：

```powershell
$ sudo ./nginx-install.sh compile

**********************************************************************

 Done. The new package has been saved to

 /home/gxcdac/compile/nginx-1.15.6/nginx_1.15.6-1_amd64.deb
 You can install it in your system anytime using:

      dpkg -i nginx_1.15.6-1_amd64.deb

**********************************************************************

 Nginx .deb package create finished !
```

如果不想自己手动编译或中途出现了一些问题，可以直接选择安装我们已经编译好的`.deb`安装包：

```powershell
$ wget https://github.com/gxcdac/gxchain-script/raw/master/nginx-script/release/nginx_1.15.6-1_amd64.deb
```

### 安装

```powershell
$ sudo ./nginx-install.sh install

Preparing to unpack .../nginx_1.15.6-1_amd64.deb ...
Unpacking nginx (1.15.6-1) over (1.15.6-1) ...
Setting up nginx (1.15.6-1) ...
 Nginx install finished !
```

### 验证

```powershell
# 版本检查
$ sudo nginx -v && sudo nginx -V

nginx version: MyServer/1.2.3 (Ubuntu)
nginx version: MyServer/1.2.3 (Ubuntu)
built by gcc 5.5.0 20171010 (Ubuntu 5.5.0-12ubuntu1~16.04)
built with OpenSSL 1.1.1  11 Sep 2018
TLS SNI support enabled
configure arguments: --prefix=/etc/nginx/  ... ...
```

> 如果你想重新安装，则可以执行卸载命令：
>
> ```powershell
> $ sudo ./nginx-install.sh uninstall
> ```



## 基础配置

### Nginx配置

替换掉Nginx默认的配置文件，使用我们优化过的配置文件：

```powershell
$ sudo ./nginx-install.sh config

Nginx default config files clean finished !
Nginx config files set finished !
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /lib/systemd/system/nginx.service.
```

在 `/etc/nginx/sites-enabled` 目录下会生成一个样例配置文件：`example.com.conf`，你可以据此模板创建自己的域名站点。

验证Nginx配置

```powershell
$ sudo nginx -t

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

我们的模板里面配置了SSL，接下来，我们还需要生成SSL证书.

### SSL配置

配置 `nginx-install.sh`参数`DOMAIN_LIST`，设置你想要配置的域名，例如：

```powershell
DOMAIN_LIST=("example.com" "example.cn" "www.example.com" "www.example.cn")
```

> 注意：确保域名已做过DNS解析和域名解析，并能够正常访问，否则 SSL 证书会生成失败

确保Nginx处于运行状态，启动Nginx：

```powershell
$ sudo systemctl start nginx
```

生成SSL证书：

```powershell
$ sudo ./nginx-install.sh certbot

Nginx SSL cert config finished !
```

> 这些域名的SSL证书，每天会定时renew.



## 安全配置

缓解DDos攻击









## 问题

- 如果服务器是在国内，在执行nginx编译的过程中，可能会发生有部分github上的tar包下载超时的情况，鉴于这种情况请直接安装我们已经编译好的`.deb`包。



## 参考资料

- https://www.vultr.com/docs/how-to-compile-nginx-from-source-on-ubuntu-16-04
- https://www.globalsign.com/en/blog/how-to-prevent-a-ddos-attack-on-a-cloud-server/
- https://www.digitalocean.com/community/tutorials/how-to-protect-an-nginx-server-with-fail2ban-on-ubuntu-14-04
- https://easyengine.io/tutorials/nginx/fail2ban/
- https://www.searchenginebay.com/protect-nginx-server-fail2ban-ubuntu/
- https://gist.github.com/Telling/7fd4bc5ee4caaff88f4b
- http://teition.com/fighting-a-ddos-attack-limiting-requests-in-nginx/
- https://github.com/karek314/ddos-deflate-nginx-cloudflare
- https://www.nginx.com/blog/mitigating-ddos-attacks-with-nginx-and-nginx-plus/
- https://www.nginx.com/blog/rate-limiting-nginx/
- https://github.com/matsumotory/http-dos-detector



