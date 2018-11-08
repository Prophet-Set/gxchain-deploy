# 公信链测试节点部署脚本

## 部署脚本使用说明

> 官方文档：https://docs.gxchain.org/zh/guide/testnet.html

### 下载脚本

> [gxchain_test_install.sh](https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_install.sh)

```shell
$ wget https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_install.sh
```

### 参数修改

1. 根据自己的需要，在启动前修改 [gxchain_test_install.sh](https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_install.sh) 中的启动参数：
   - `WORKSPACE_PATH`：公信链运行的目录
   - `RPC_ENDPOINT`：RPC监听的端口地址
   - `P2P_ENDPOINT`：P2P监听的端口地址

2. 查看服务器防火墙以及云服务器的安全规则配置（例如阿里云的ECS的安全规则配置），确保对`rpc`和`p2p`端口开放

### 执行脚本

```shell
$ bash +x gxchain_test_install.sh
```

查看日志 `testnet_node/logs/witness.log` 输出，等待区块同步完成

```

...

2018-11-08T12:54:18 th_a:invoke handle_block         handle_block ] Got block: #8703793 time: 2018-11-08T12:54:18 latency: 33 ms from: init6  irreversible: 8703773 (-20)	application.cpp:496
2018-11-08T12:54:21 th_a:invoke handle_block         handle_block ] Got block: #8703794 time: 2018-11-08T12:54:21 latency: 33 ms from: miner9  irreversible: 8703773 (-21)application.cpp:496
2018-11-08T12:54:24 th_a:invoke handle_block         handle_block ] Got block: #8703795 time: 2018-11-08T12:54:24 latency: 33 ms from: init8  irreversible: 8703773 (-22)	application.cpp:496
2018-11-08T12:54:27 th_a:invoke handle_block         handle_block ] Got block: #8703796 time: 2018-11-08T12:54:27 latency: 34 ms from: init5  irreversible: 8703773 (-23)	application.cpp:496
2018-11-08T12:54:30 th_a:invoke handle_block         handle_block ] Got block: #8703797 time: 2018-11-08T12:54:30 latency: 32 ms from: init7  irreversible: 8703775 (-22)	application.cpp:496
2018-11-08T12:54:33 th_a:invoke handle_block         handle_block ] Got block: #8703798 time: 2018-11-08T12:54:33 latency: 33 ms from: init9  irreversible: 8703777 (-21)	application.cpp:496
2018-11-08T12:54:36 th_a:invoke handle_block         handle_block ] Got block: #8703799 time: 2018-11-08T12:54:36 latency: 32 ms from: init2  irreversible: 8703778 (-21)	application.cpp:496

...
```









