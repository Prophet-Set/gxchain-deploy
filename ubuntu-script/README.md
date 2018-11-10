# 服务器优化配置

## 背景

一般，我们在买完云服务器之后，需要修改服务器默认的配置。例如，修改hostname、新增普通用户、修改ssh登录配置、更新安装包、磁盘挂载、swap分区配置、防火墙设置、内核安全设置等等一系列措施。这些操作费时费力，还容易出错，弄不好一天的时间就过去了。

通过此脚本，则可以分分钟准确地完成以上一系列配置。

## 适用

- 适用于 **阿里云** **新购**的 **Ubuntu 16.04 LTS** 服务器
- 版本：`Ubuntu 16.04 4.4.0-117-generic`
- 其他linux版本的请自行修改，大同小异，只是一些命令有些许区别

## 功能

该脚本对**新服务器**的处理，主要如下：

- 修改默认`hostname`

- 新建普通用户并做一些设置

  - 创建`/home`目录下的用户目录
  - 创建用户目录下一些必要的文件及文件夹：`.ssh`,  `authorized_keys`, `.bashrc`, `.profile`
  - 设置普通用户密码
  - 添加到`sudo`权限
  - 设置ssh登录权限

- 优化`sshd_config`配置

  > 参考：https://www.cyberciti.biz/tips/linux-unix-bsd-openssh-server-best-practices.html
  >
  > 说明：只是初步优化配置，并未强制关闭密码登录，未强制开启ssh key登录，不然在ssh key未配置的情况下，等该脚本执行完，你就无法登录服务器了。
  >
  > ssh登录需要等到后面再去单独设置

  主要如下：

  - 修改默认端口
  - 关闭root登录权限
  - 上一步新建的普通用户的登录权限

- 更新软件包

  - `apt-get update` 

  - `apt-get upgrade`

  - 安装gxchain依赖包及常用的软件包，可根据自己的需求自行配置

    ```shell
    apt-get install -y ntp htop zsh git-core software-properties-common libstdc++-7-dev
    ```

- 系统配置优化

  - 内核安全优化 `/etc/sysctl.conf`
  - 设置 language 为 `en_US.UTF-8`

- 磁盘分区处理

  > 说明：阿里云的ECS默认挂载了系统盘，而该脚本主要是对**数据盘**做分区处理，系统盘无法处理

  - 新增 1G 的 `swap` 分区
  - 新建 `/mydata` 目录，并将数据盘挂载到 `/mydata` 目录下



## 执行Ububtu初始化脚本

### 下载脚本

> [ubuntu_optimize](https://github.com/gxcdac/gxchain-script/blob/master/ubuntu-script/ubuntu_optimize.sh)

```shell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-script/master/ubuntu-script/ubuntu_optimize.sh
```

### 修改脚本默认参数

1. 设置新建的普通用户名，例如：

   ```shell
   MY_NEW_USER='gxchainuser'
   ```

2. 设置数据盘

   - 登录服务器，执行命令 `fdisk -l` 查看数据盘的路径，例如为 `/dev/vda1`

     ```shell
     $ sudo fdisk -l
     
     ## 输出如下信息
     Disk /dev/vda1: 42.9 GB, 42949672960 bytes, 83886080 sectors
     Units = sectors of 1 * 512 = 512 bytes
     Sector size (logical/physical): 512 bytes / 512 bytes
     I/O size (minimum/optimal): 512 bytes / 512 bytes
     Disk label type: dos
     Disk identifier: 0x0008d73a
     ```

   - 则 `MY_DATA_DEV`  配置为 `vda1` ：

     ```shell
     MY_DATA_DEV='vda1'
     ```

3. 设置 ssh 登录端口。找到脚本中的下面这段代码，将 41837 改成你想设置的端口：

   ```shell
   sed -ri 's/Port 22/Port 41837/g' /etc/ssh/sshd_config
   ```



### 执行脚本

1. 执行脚本

   ```shell
   $ bash +x aliyun_ubuntu_server_init.sh
   ```

2. 按照提示，输入你想要设置的`hostname`，例如: `gxchain-test-node-01`

3. 途中会有要出入'Y'或按回车键的地方

4. 耐心等待脚本执行完毕

5. 若无问题，最后会输出如下内容：

   ```tex
   eth0 is 10.10.10.06
   hostname is gxchain-test-node-01
   username is gxchainuser
   port is 41837
   password is BmY1Fm2prNT*lZWSmEYMzuI1rg8S*lSl
   -----------END-----------
   ```

6. 保存好密码，用于后期登录：

   ```shell
   $ ssh -p 41837 gxchainuser@10.10.10.06
   
   enter password: BmY1Fm2prNT*lZWSmEYMzuI1rg8S*lSl
   ```



## 安全

### SSH Key登录配置

> 根据自己需要，这一步也可以省略

一般我们登录生产机器，会通过跳板机去登录，我们需要在跳板机上生成SSH公私钥，用于登录生产机器

1. 登录跳板机。

2. 生成ssh key，可以修改后面的备注remark。

   ```shell
   $ ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_aws_$(date +%Y-%m-%d) -C "remark"
   ```

3. 安装ssh public key，将上一步生成的ssh public key安装到指定的生产机上。

   > 替换`.pub`文件名、`user`和`remote-server-ip`

   ```shell
   $ ssh-copy-id -i id_rsa_aws_2015-03-04.pub user@remote-server-ip
   ```

4. 使用新生成的ssh key 登录生产机，并再次优化sshd_config配置，强制关闭密码登录，强制开启pubkey登录

   1. 使用ssh key登录，例如：

      ```shell
      $ ssh -i ssh_private_file -p 41837 gxchainuser@101.71.23.9
      ```

   2. 优化`sshd_config`配置，强制关闭密码登录，强制开启pubkey登录，单独执行下面的脚本：

      ```shell
      sshd_pwd_auth_tunning(){
          sed -ri 's/#PasswordAuthentication\s+yes/PasswordAuthentication\tno/g;' /etc/ssh/sshd_config
          if ! grep 'AuthenticationMethods publickey' /etc/ssh/sshd_config >/dev/null;then echo "AuthenticationMethods publickey" >> /etc/ssh/sshd_config;fi
      }
      
      sshd_pwd_auth_tunning
      
      service sshd restart
      ```



### 防火墙设置

> **注意**：使用该脚本时，请务必认真检查要设置规则的IP与端口，避免服务器及应用功能异常！

#### 下载脚本

> [ubuntu_firewall](https://github.com/gxcdac/gxchain-script/blob/master/ubuntu-script/ubuntu_firewall.sh)

```shell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-script/master/ubuntu-script/ubuntu_firewall.sh
```

#### 配置 INPUT 规则

找到 `ubuntu_firewall.sh` 中 `input_rules()`  方法中的下面这段内容，按照你的实际需求，对要开发的端口和IP进行配置

```shell
###### Add the input rules here:
# iptables -A INPUT -p tcp -m state --state NEW -m tcp -s <source_address> --dport <destnation_port> -j ACCEPT
###### Add an end

# ssh 端口只对跳板机开放
iptables -A INPUT -p tcp -m state --state NEW -m tcp -s xxx.xxx.xxx.xxx --dport 22 -j ACCEPT

# 80、443 端口只对 SLB 开放
iptables -A INPUT -p tcp -m state --state NEW -m tcp -s xxx.xxx.xxx.xxx --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp -s xxx.xxx.xxx.xxx --dport 443 -j ACCEPT
  
# allow your own app port
iptables -A INPUT -p tcp -m state --state NEW -m tcp -s xxx.xxx.xxx.xxx --dport xxx -j ACCEPT

```

#### 配置 OUTPUT 规则

找到 `ubuntu_firewall.sh` 中 `output_rules()`  方法中的下面这段内容，按照你的实际需求，对要开发的端口和IP进行配置

```shell
###### Add the output rules here:
# iptables -A OUTPUT -p tcp -m state --state NEW -d <destnation_address> --dport <destnation_port> -j ACCEPT
###### Add an end

# allow DNS-NTP-FTP-HTTP-HTTPS-SMTP
PORTS1="53 123 21 80 443 25"
for port1 in $PORTS1;do iptables -A OUTPUT -p udp -m state --state NEW --dport $port1 -j ACCEPT;done

# allow your custom SSH port
PORTS2="22"
for port2 in $PORTS2;do iptables -A OUTPUT -p tcp -m state --state NEW --dport $port2 -j ACCEPT;done

# allow your own app port
PORTS2="22"
for port2 in $PORTS2;do iptables -A OUTPUT -p tcp -m state --state NEW --dport $port2 -j ACCEPT;done
```

#### 执行脚本

必须要以root的权限进行运行

```shell
#bash +x ubuntu_firewall.sh
```



#### 阿里云安全组设置

如果你用的是阿里云的ECS服务，我们还需要做一道防御，将上面配置的防火墙规则同步到ECS安全组配置中去。



## 其他配置

- 配置服务器快照策略
- 配置磁盘快照策略

