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

配置`nginx-install.sh`脚本参数，例如：

```powershell
#设置Nginx脚本目录
NGINX_SCRIPT_HOME="/home/gxcchainuser/gxchain-script/nginx-script"
```

配置`nginx-compile.sh`脚本参数，例如：

```powershell
# 设置Nginx编译构建的目录
BUILD_HOME="/home/gxcchainuser/compile"
# 配置Nginx最新stable版本
NGINX_VERSION='1.14.1'

# 修改Nginx源码，对Nginx的名称和版本进行混淆
MIX_NGINX_NAME='MyServer'
MIX_NGINX_VERSION='1.2.3'
```

### 编译

```powershell
$ sudo ./nginx-install.sh compile

**********************************************************************

 Done. The new package has been saved to

 /home/gxcdac/compile/nginx-1.14.1/nginx_1.14.1-1_amd64.deb
 You can install it in your system anytime using:

      dpkg -i nginx_1.14.1-1_amd64.deb

**********************************************************************

 Nginx .deb package create finished !
```

### 安装

```powershell
$ sudo ./nginx-install.sh install

Preparing to unpack .../nginx_1.14.1-1_amd64.deb ...
Unpacking nginx (1.14.1-1) over (1.14.1-1) ...
Setting up nginx (1.14.1-1) ...
 Nginx install finished !
```

### 验证

```powershell
# 版本检查
$ nginx -v

nginx version: MyServer/1.2.3 (Ubuntu)
```

### 卸载

```powershell
$ sudo ./nginx-install.sh uninstall

Nginx uninstall finished !
```



## 配置

### Nginx配置

替换掉Nginx默认的配置文件，使用我们优化过的配置文件：

```shell
$ sudo ./nginx-install.sh config
```



### SSL配置



### 配置文件

### HTTPS配置

> https://www.linode.com/docs/security/ssl/install-lets-encrypt-to-create-ssl-certificates/





## 安全配置

DDos攻击防护































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



