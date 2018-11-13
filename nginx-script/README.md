# Nginx优化配置

## 安装

### 脚本下载

```shell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-script/master/nginx-script/nginx-compile.sh
$ chmod +x nginx-compile.sh
```

### 参数配置

根据自己的需要设置以下几个参数：

```shell
# 设置Nginx编译构建的目录
BUILD_HOME="/mydata/source/"
# 要下载Nginx版本
NGINX_VERSION='1.14.1'

# 修改Nginx源码，对Nginx的名称和版本进行混淆
MIX_NGINX_NAME='MyServer'
MIX_NGINX_VERSION='1.2.3'
```

### 编译安装

```shell
$ sudo ./nginx-compile.sh
```

### 检查

```shell
# 版本检查
$ nginx -v
# nginx version: MyServer/1.2.3 (Ubuntu)

# 启动 | 停止 | 重载配置
$ systemctl start | stop | reload nginx
```



## 配置

### 配置文件

```shell



```





### HTTPS配置

> https://www.linode.com/docs/security/ssl/install-lets-encrypt-to-create-ssl-certificates/





## 安全配置

DDos攻击防护











































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



