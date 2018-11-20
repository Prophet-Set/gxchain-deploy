# 公信链测试节点部署

使用我们的脚本可以快速便捷地部署公信链测试节点，也能够有效地管理公信链节点，省去敲击一大串复杂的命令行的工作。



## 下载脚本

> [gxchain_test_script.sh](https://github.com/gxcdac/gxchain-script/tree/master/gxchain-test-script/gxchain_test_script.sh)

```powershell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-script/master/gxchain-test-script/gxchain_test_script.sh

$ chmod +x gxchain_test_script.sh
```



## 参数配置

脚本默认参数配置如下：

```powershell
#set -x
# gxchain user
CMD_USER=gxchainuser

# port config
RPC_ENDPOINT="127.0.0.1:28090"
P2P_ENDPOINT="0.0.0.0:9999"
SEED_NODES='["testnet.gxchain.org:6789"]'

# workspace config
WORKSPACE_PATH=/mydata
GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json
DATA_DIR=$WORKSPACE_PATH/testnet_node
PROGRAMS_DIR=$WORKSPACE_PATH/programs

# witness config
WITNESS_ID="1.6.1"
PUBLICK_KEY="GXC6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
PRIVATE_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
```

根据自己服务器的环境，主要配置以下几个参数：

##### 运行用户配置

- `CMD_USER`：设置公信链运行的用户（非root）。例如：`CMD_USER=gxchainuser`

##### 运行端口配置

- `RPC_ENDPOINT`：RPC监听的地址端口。例如：`RPC_ENDPOINT="127.0.0.1:28090"`

  >  强烈建议RPC服务通过Nginx对外提供服务，这里ip地址填写为`127.0.0.1`或`localhost`。

- `P2P_ENDPOINT`：P2P监听的地址端口。例如：`P2P_ENDPOINT="0.0.0.0:9999"`

  > p2p的地址不能配置为 `127.0.0.1`，否则会影响区块的接收
  >
  > p2p也可以使用Nginx对外提供服务

- `SEED_NODES`：种子节点，默认为 `SEED_NODES='["testnet.gxchain.org:6789"]'`

> **注意**：
>
> 查看服务器防火墙以及云服务器的安全规则配置（例如阿里云的ECS的安全规则配置），确保对`rpc`和`p2p`端口开放。

##### 工作目录配置

- `WORKSPACE_PATH`：公信链运行目录。例如：`WORKSPACE_PATH=/mydata`

##### 见证人配置

- `WITNESS_ID`：测试账号的见证人ID，例如： `1.6.31`
- `PUBLICK_KEY`：测试账号的公钥

- `PRIVATE_KEY`：测试账号的私钥

> 注册测试钱包：https://testnet.wallet.gxchain.org
>
> 申请测试Token：http://blockcity.mikecrm.com/2SVDb67
>
> 升级测试账户：普通会员 ——> 终生会员 ——> 公信节点候选人 1.6.31



## 部署安装

执行安装命令，下载安装公信链最新测试版本：

```powershell
$ ./gxchain_test_script.sh install
```

### 同步区块

启动测试链，开始从种子节点同步区块

```powershell
$ ./gxchain_test_script.sh sync_block
```

查看区块同步日志 `testnet_node/logs/witness.log` ，等待区块同步完成。

当区块编号以  10000 递增时，表示区块正在同步。当区块编号以  1 递增时，表示区块同步完成，公信链整个测试链的数据约在1.5G左右，一个小时之内就可以同步完成。

```

2018-11-11T12:58:54        th_a:?unnamed?       reset_p2p_node ] Adding seed node 106.14.180.117:6789			application.cpp:152
2018-11-11T12:58:54        th_a:?unnamed?       reset_p2p_node ] Configured p2p node to listen on 0.0.0.0:8659			application.cpp:194
2018-11-11T12:58:54        th_a:?unnamed? reset_websocket_serv ] Configured websocket rpc to listen on 0.0.0.0:38067			application.cpp:269
2018-11-11T12:58:54        th_a:?unnamed?       plugin_startup ] data transaction plugin startup			data_transaction_plugin.cpp:63
2018-11-11T12:58:54        th_a:?unnamed?       plugin_startup ] witness plugin:  plugin_startup() begin			witness.cpp:121
2018-11-11T12:58:54        th_a:?unnamed?       plugin_startup ] No witnesses configured! Please add witness IDs and private keys to configuration.		witness.cpp:137
2018-11-11T12:58:54        th_a:?unnamed?       plugin_startup ] witness plugin:  plugin_startup() end			witness.cpp:138
2018-11-11T12:58:54        th_a:?unnamed?                 main ] Started witness node on a chain with 0 blocks.			main.cpp:216
2018-11-11T12:58:54        th_a:?unnamed?                 main ] Chain ID is c2af30ef9340ff81fd61654295e98a1ff04b23189748f86727d0b26b40bb0ff4			main.cpp:217

...

2018-11-11T13:02:14 th_a:invoke handle_block         handle_block ] Got block: #960000 time: 2018-01-17T18:44:30 latency: 25726664888 ms from: init3  irreversible: 959990 (-10)			application.cpp:496
2018-11-11T13:02:16 th_a:invoke handle_block         handle_block ] Got block: #970000 time: 2018-01-18T03:12:09 latency: 25696207587 ms from: init2  irreversible: 969992 (-8)			application.cpp:496
2018-11-11T13:02:18 th_a:invoke handle_block         handle_block ] Got block: #980000 time: 2018-01-18T11:39:39 latency: 25665759432 ms from: init10  irreversible: 979992 (-8)			application.cpp:496

...

2018-11-10T05:47:51 th_a:invoke handle_block         handle_block ] Got block: #8749837 time: 2018-11-10T05:47:51 latency: 33 ms from: init5  irreversible: 8749822 (-15)			application.cpp:496
2018-11-10T05:47:54 th_a:invoke handle_block         handle_block ] Got block: #8749838 time: 2018-11-10T05:47:54 latency: 36 ms from: init6  irreversible: 8749823 (-15)			application.cpp:496
2018-11-10T05:47:57 th_a:invoke handle_block         handle_block ] Got block: #8749839 time: 2018-11-10T05:47:57 latency: 30 ms from: miner8  irreversible: 8749824 (-15)			application.cpp:496

...

```



### 生成config.ini

公信链启动后，会在 `testnet_node` 目录下生成 `config.ini` 配置文件，用于公信链运行参数的配置。使用配置文件管理启动参数优于以命令行的方式管理启动参数，也便于后期公信链的管理。

使用如下命令，可以将脚本中的参数配置写入到 `config.ini` 配置文件中

```powershell
$ ./gxchain_test_script.sh gen_config
```



## 公信链管理

**开机自启动配置**

将如下内容，添加到  `/etc/rc.local` 配置末尾，具体路劲以实际情况为准

```shell
/bin/sh /mydata/gxchain_test_script.sh start
```

> 注意：要放到  `exist 0` 指令之前。

**查看公信链状态**

```powershell
$ ./gxchain_test_script.sh status
```

**启动公信链**

```powershell
$ ./gxchain_test_script.sh start
```

日志输出：

```
2018-11-12T03:43:41        th_a:?unnamed?       reset_p2p_node ] Adding seed node 106.14.180.117:6789			application.cpp:152
2018-11-12T03:43:41        th_a:?unnamed?       reset_p2p_node ] Configured p2p node to listen on 0.0.0.0:9999			application.cpp:194
2018-11-12T03:43:41        th_a:?unnamed? reset_websocket_serv ] Configured websocket rpc to listen on 0.0.0.0:28090			application.cpp:269
2018-11-12T03:43:41        th_a:?unnamed?       plugin_startup ] data transaction plugin startup			data_transaction_plugin.cpp:63
2018-11-12T03:43:41        th_a:?unnamed?       plugin_startup ] witness plugin:  plugin_startup() begin			witness.cpp:121
2018-11-12T03:43:41        th_a:?unnamed?       plugin_startup ] No witnesses configured! Please add witness IDs and private keys to configuration.			witness.cpp:137
2018-11-12T03:43:41        th_a:?unnamed?       plugin_startup ] witness plugin:  plugin_startup() end			witness.cpp:138
2018-11-12T03:43:41        th_a:?unnamed?                 main ] Started witness node on a chain with 8803779 blocks.			main.cpp:216
2018-11-12T03:43:41        th_a:?unnamed?                 main ] Chain ID is c2af30ef9340ff81fd61654295e98a1ff04b23189748f86727d0b26b40bb0ff4			main.cpp:217
2018-11-12T03:43:42 th_a:invoke handle_block         handle_block ] Got block: #8803933 time: 2018-11-12T03:43:42 latency: 35 ms from: init7  irreversible: 8803923 (-10)			application.cpp:496
2018-11-12T04:08:18 th_a:invoke handle_block         handle_block ] Got block: #8804419 time: 2018-11-12T04:08:18 latency: 35 ms from: miner7  irreversible: 8804404 (-15)			application.cpp:496

...

```

当测试账户的投票数达到前21名时，测试节点就可以产生区块，生产区块的日志如下：

```verilog
...

2018-11-15T03:22:42 th_a:Witness Block Production block_production_loo ] Generated block #14643980 with timestamp 2018-11-15T03:22:42 at time 2018-11-15T03:22:42   witness.cpp:183

...

```

**停止公信链**

```powershell
$ ./gxchain_test_script.sh stop
```

日志输出：

```

...

2018-11-12T03:35:53        asio:?unnamed?           operator() ] Caught SIGINT attempting to exit cleanly			main.cpp:207
2018-11-12T03:35:53        th_a:?unnamed?                 main ] Exiting from signal 2			main.cpp:220
2018-11-12T03:35:53        th_a:?unnamed?      plugin_shutdown ] data transaction plugin shutdown			data_transaction_plugin.cpp:68
2018-11-12T03:35:53        th_a:?unnamed?                close ] head_block_num: 8803779, last_irreversible_block_num: 8803771			db_management.cpp:204
2018-11-12T03:35:53        th_a:?unnamed?                close ] Rewinding from 8803779 to 8803771			db_management.cpp:205
```

**重启公信链**

```powershell
$ ./gxchain_test_script.sh restart
```



## 常见问题

- 公信链启动之后，没有开始同步区块，请确保防火墙对RPC与P2P端口开放。



## 参考资料

- https://docs.gxchain.org/zh/guide/testnet.html