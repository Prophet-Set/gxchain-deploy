# GXChain生产节点部署



## 架构

生产节点的部署架构不同于 [测试节点三合一的架构](https://github.com/gxcdac/gxchain-deploy/blob/master/gxchain-script/README-test.md#%E6%9E%B6%E6%9E%84) ，为了保证生产节点的高稳定性、可用性和扩展性，每种角色通常要分开部署。

我们以最基础的架构为例：

![GXChain Prod Node](https://img.i7years.com/gxcdac/GXChain%20Prod%20Node1.png)

> -  [GXChain API服务器搭建](https://docs.gxchain.org/zh/guide/api_server.html)
> - [公信节点部署](https://docs.gxchain.org/zh/guide/witness.html)



### 要求

每种类型的服务器的部署要求如下：

| 类型      | 配置要求                                         | P2P PORT | RPC PORT | SEED PORT | 备注                                                         |
| --------- | ------------------------------------------------ | -------- | -------- | --------- | :----------------------------------------------------------- |
| Seed Node | 内存：32 GB+<br />硬盘：200 GB+<br />带宽：20MB+ | ✅        | 🚫        | 😊         | 种子节点只需要开启P2P端口，用于对外提供区块同步服务<br />P2P端口不能本地(127.0.0.1)监听，会影响区块同步<br />P2P端口可以使用Nginx SSL协议来反向代理 |
| API Node  | 内存：16GB+<br />硬盘：100GB+<br />带宽：10MB+   | 🚫        | ✅        | 😊         | API节点只需要开启RPC接口，对外提供API服务<br />RPC端口可以本地(127.0.0.1)监听<br />RPC端口可以使用Nginx SSL协议来反向代理 |
| BP Node   | 内存：32 GB+<br />硬盘：200 GB+<br />带宽：20MB+ | 🚫        | 🚫        | 😊         | 能主动对外建立TCP连接即可，不需要其他节点来主动连接BP节点，因此我们可以关闭它的RPC与P2P端口 |

> ✅：开放
>
> 🚫：禁止
>
> 😊：可配可不配。

程序里面已经硬编码了8个默认的种子节点，程序启动之后，会默认去连接由公信宝官方维护的8个种子节点，它们分布如下：

- 🇨🇳上海：`106.14.226.179:6789`
- 🇨🇳深圳：`39.108.80.220:6789`
- 🇨🇳张家口：`47.92.117.128:6789`
- 🇺🇸美国：`47.254.18.74:6789`
- 🇯🇵日本：`47.74.22.124:6789`
- 🇸🇬新加坡：`47.88.158.101:6789`
- 🇭🇰香港：`47.52.114.135:6789`
- 🇩🇪德国：`47.254.146.219:6789`



### 节省成本

云服务器的带宽是非常昂贵的资源，费用开销比较大。如果部署三台服务器，并且单独为每台服务器配置20M+的带宽，那总共的带宽费用就是60MB+的费用。我们可以采用如下方式节省费用开支：

1. 多应用共享NAT带宽。将VPC内网所有服务器的网络请求全部用一个NAT网关来进行转发。可能只需要配置30~40MB左右的带宽即可满足实际需求。参考：[多应用共享公网带宽](https://help.aliyun.com/document_detail/32327.html?spm=a2c4g.11174283.6.568.7c987d2ew1TSLV)
2. 开启按流量计费模式。
3. 开启共享流量包。



## 下载脚本

```powershell
$ wget https://raw.githubusercontent.com/gxcdac/gxchain-deploy/master/gxchain-script/gxchain-prod.sh

$ chmod +x gxchain-prod.sh
```



## 参数配置

脚本默认参数配置如下：

```powershell
# gxchain user
CMD_USER=gxchainuser

# port config
RPC_ENDPOINT="127.0.0.1:28090"
P2P_ENDPOINT="0.0.0.0:9999"
#SEED_NODES='["your_seed_ip:6789"]'

# workspace config
WORKSPACE_PATH=/mydata
#GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json
DATA_DIR=$WORKSPACE_PATH/trusted_node
PROGRAMS_DIR=$WORKSPACE_PATH/programs

# witness config
WITNESS_ID="1.6.1"
PUBLICK_KEY="GXC6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
PRIVATE_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
```

根据自己服务器的环境，主要配置以下几个参数：

##### 运行用户配置

- `CMD_USER`：设置GXChain运行的用户（非root）。例如：`CMD_USER=gxchainuser`

##### 运行端口配置

结合每台服务器的实际用途来进行配置，按照前面提到的原则来选择端口开放与否：

- `RPC_ENDPOINT`：RPC监听的地址端口。例如：`RPC_ENDPOINT="127.0.0.1:28090"`
- `P2P_ENDPOINT`：P2P监听的地址端口。例如：`P2P_ENDPOINT="0.0.0.0:9999"`
- `SEED_NODES`：种子节点。

##### 工作目录配置

- `WORKSPACE_PATH`：GXChain运行目录。例如：`WORKSPACE_PATH=/mydata`

##### 见证人配置

- `WITNESS_ID`：BP账号的见证人ID，例如： `1.6.31`
- `PUBLICK_KEY`：BP账号的见证人公钥
- `PRIVATE_KEY`：BP账号的见证人私钥

> **注意**：这里不是配置BP账号的公私钥，而是由BP账号单独生成一对公私钥作为见证人来进行区块的生产。即使见证人账户公私钥被盗，也不会影响到BP主账号里面的资产。
>
> 参见：[账户安全](https://github.com/gxcdac/gxchain-deploy/blob/master/gxchain-script/README-prod.md#%E8%B4%A6%E6%88%B7%E5%AE%89%E5%85%A8)



## 部署安装

执行安装命令，下载安装GXChain最新版本：

```powershell
$ sudo ./gxchain-prod.sh install
```

### 同步区块

启动GXChain，开始从种子节点同步区块

```powershell
$ ./gxchain-prod.sh sync_block
```

查看区块同步日志 `trusted_node/logs/witness.log` ，等待区块同步完成。

![gxchain-sync-block-log](https://img.i7years.com/gxcdac/gxchain-sync-block-log1.png)

生产区块每2~3min同步一次。当区块编号以  10000 递增时，表示正在同步历史区块。当区块编号以  1 递增时，表示历史区块同步完成，开始同步最新区块。生产数据量约在35G左右，13Hour左右就可以同步完成。

#### Tips

在最初区块的同步阶段，对服务器的配置要求不是很高，如下：

![gxchain-sync-block-monitor](https://img.i7years.com/gxcdac/gxchain-sync-block-monitor.png)

`2核/4G/1M带宽` 即可满足同步需求。待区块同步完成之后，再升级到官方要求的配置，可节省一段时间内的成本。



### 生成config.ini

GXChain启动后，会在 `trusted_node` 目录下生成 `config.ini` 配置文件，用于GXChain运行参数的配置。

使用配置文件管理启动参数优于以命令行的方式管理启动参数，也便于后期GXChain的管理。

使用如下命令，可以将脚本中的参数配置写入到 `config.ini` 配置文件中

```powershell
$ ./gxchain-prod.sh gen_config
```



## GXChain管理

**开机自启动配置**

该部分内容的配置，已在脚本中配置，与`./gxchain-prod.sh gen_config`一起执行。脚本如下：

```shell
gen_config(){
	
    ...
    
    grep '/mydata/gxchain-prod.sh' /etc/rc.local &> /dev/null
    if [ $? != 0 ] ; then
      sed -i '/exit\s0/d' /etc/rc.local
      echo -e '/bin/sh /mydata/gxchain-prod.sh start\nexit 0' >> /etc/rc.local
    fi
    
    echo -e "$GREEN GXChain config start on boot Finished. $NO_COLOR"
    
    return 0
}
```

**查看GXChain状态**

```powershell
$ ./gxchain-prod.sh status
```

**启动GXChain**

```powershell
$ ./gxchain-prod.sh start
```

**停止GXChain**

```powershell
$ ./gxchain-prod.sh stop
```

**重启GXChain**

```powershell
$ ./gxchain-prod.sh restart
```



## Nginx反向代理RPC & P2P端口

参考 [测试链部署](https://github.com/gxcdac/gxchain-deploy/blob/master/gxchain-script/README-test.md#nginx%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86rpc--p2p%E7%AB%AF%E5%8F%A3)



## 账户安全

> 生产BP节点必须配置

GXChain节点配置，需要将公信账户的公私钥配置到`config.ini`文件中，一旦服务器被黑入，极有可能出现公信账号被盗的风险，存在非常大的安全隐患。

为了避免这种风险，我们可以采取以下两种措施来避免此种风险：

- 对公信账户进行多签。即使用几个其他的公信账户的私钥来共同签署公信节点的账号。
- 见证人账户配置。详见：[更新公信节点私钥](https://github.com/gxcdac/gxchain-deploy/wiki/%E6%9B%B4%E6%96%B0%E5%85%AC%E4%BF%A1%E8%8A%82%E7%82%B9%E7%A7%81%E9%92%A5)



## 注意事项

- 建议将GXChain部署安装到单独的数据盘上。比如，新建`/mydata`目录，单独挂载一块数据盘，用于GXChain部署。
- GXChain管理脚本 `gxchain-prod.sh` 放置的路径，不要轻易改变，以免导致GXChain开机自启动失效，建议放置在GXChain部署目录下。例如：`/mydata`目录。



## 常见问题

- GXChain启动之后，没有开始同步区块，请确保防火墙对P2P端口开放。



## 参考资料

-  [GXChain API服务器搭建](https://docs.gxchain.org/zh/guide/api_server.html)
- [公信节点部署](https://docs.gxchain.org/zh/guide/witness.html)