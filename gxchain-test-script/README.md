# 公信链测试节点部署脚本

## 部署脚本说明

> 官方文档：https://docs.gxchain.org/zh/guide/testnet.html

### 下载脚本

> [gxchain_test_script.sh](https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_script.sh)

```powershell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-script/master/gxchain-test-script/gxchain_test_script.sh

$ chmod +x gxchain_test_script.sh
```

### 参数配置

1. 根据自己的需要，在启动前修改 [gxchain_test_script.sh](https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_script.sh) 中的启动参数：

   - `CMD_USER`：设置公信链运行的用户（非root）

   - `WORKSPACE_PATH`：公信链运行目录
   - `RPC_ENDPOINT`：RPC监听的地址端口
   - `P2P_ENDPOINT`：P2P监听的地址端口
   - `SEED_NODES`：种子节点，默认即可

2. 查看服务器防火墙以及云服务器的安全规则配置（例如阿里云的ECS的安全规则配置），确保对`rpc`和`p2p`端口开放

### 安装测试链

下载公信链最新测试版本

```powershell
$ ./gxchain_test_script.sh install
```

### 同步区块

启动测试链，开始从种子节点同步区块

```powershell
$ ./gxchain_test_script.sh sync_block
```

查看区块同步日志 `testnet_node/logs/witness.log` ，等待区块同步完成，当 `Got block` 后面的编号，开始按照 1 递增时，表示区块已经同步完成，整个测试链的数据在1.5G左右。

```

...

2018-11-10T05:47:27 th_a:invoke handle_block         handle_block ] Got block: #8749829 time: 2018-11-10T05:47:27 latency: 30 ms from: init7  irreversible: 8749808 (-21)			application.cpp:496
2018-11-10T05:47:30 th_a:invoke handle_block         handle_block ] Got block: #8749830 time: 2018-11-10T05:47:30 latency: 37 ms from: miner6  irreversible: 8749809 (-21)			application.cpp:496
2018-11-10T05:47:33 th_a:invoke handle_block         handle_block ] Got block: #8749831 time: 2018-11-10T05:47:33 latency: 30 ms from: miner9  irreversible: 8749815 (-16)			application.cpp:496
2018-11-10T05:47:36 th_a:invoke handle_block         handle_block ] Got block: #8749832 time: 2018-11-10T05:47:36 latency: 35 ms from: init0  irreversible: 8749817 (-15)			application.cpp:496
2018-11-10T05:47:39 th_a:invoke handle_block         handle_block ] Got block: #8749833 time: 2018-11-10T05:47:39 latency: 36 ms from: init3  irreversible: 8749818 (-15)			application.cpp:496
2018-11-10T05:47:42 th_a:invoke handle_block         handle_block ] Got block: #8749834 time: 2018-11-10T05:47:42 latency: 36 ms from: init1  irreversible: 8749819 (-15)			application.cpp:496
2018-11-10T05:47:45 th_a:invoke handle_block         handle_block ] Got block: #8749835 time: 2018-11-10T05:47:45 latency: 31 ms from: init2  irreversible: 8749820 (-15)			application.cpp:496
2018-11-10T05:47:48 th_a:invoke handle_block         handle_block ] Got block: #8749836 time: 2018-11-10T05:47:48 latency: 31 ms from: bob  irreversible: 8749821 (-15)			application.cpp:496
2018-11-10T05:47:51 th_a:invoke handle_block         handle_block ] Got block: #8749837 time: 2018-11-10T05:47:51 latency: 33 ms from: init5  irreversible: 8749822 (-15)			application.cpp:496
2018-11-10T05:47:54 th_a:invoke handle_block         handle_block ] Got block: #8749838 time: 2018-11-10T05:47:54 latency: 36 ms from: init6  irreversible: 8749823 (-15)			application.cpp:496
2018-11-10T05:47:57 th_a:invoke handle_block         handle_block ] Got block: #8749839 time: 2018-11-10T05:47:57 latency: 30 ms from: miner8  irreversible: 8749824 (-15)			application.cpp:496

...

```



## config.ini

### 初始化配置

公信链启动后，会在 `testnet_node` 目录下生成 `config.ini` 配置文件，用于公信链启动参数的配置。

使用配置文件管理启动参数优于以命令行的方式管理启动参数。

```powershell
$ ./gxchain_test_script.sh generate_config
```



## 公信链管理

查看公信链状态

```powershell
$ ./gxchain_test_script.sh status
```

重启公信链

```powershell
$ ./gxchain_test_script.sh restart
```

停止公信链

```powershell
$ ./gxchain_test_script.sh stop
```

开始公信链

```powershell
$ ./gxchain_test_script.sh stop
```

