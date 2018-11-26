# GXChain部署指南

## 部署文档

- [测试节点部署](https://github.com/gxcdac/gxchain-deploy/wiki/GXChain%E6%B5%8B%E8%AF%95%E8%8A%82%E7%82%B9%E9%83%A8%E7%BD%B2)
- [生产节点部署](https://github.com/gxcdac/gxchain-deploy/wiki/GXChain%E7%94%9F%E4%BA%A7%E8%8A%82%E7%82%B9%E9%83%A8%E7%BD%B2)

## 脚本用法

> 以生产脚本为例

**帮助信息**

```powershell
$ ./gxchain-prod.sh h

Usage: ./gxchain-prod.sh [command]

command:
    h            show help info.
    install      install gxchain program.
    sync_block   start to synchronize block from other seed nodes.
    gen_config   generate gxchain config file: config.ini
    start        start gxchain.
    stop         stop gxchain.
    restart      restart gxchain.
    status       show gxchain running status.
```

**安装GXChain**

```powershell
$ ./gxchain-prod.sh install
```

**开始同步区块**

```powershell
$ ./gxchain-prod.sh sync_block
```

**生成配置文件**

```powershell
$ ./gxchain-prod.sh gen_config
```

**启动公信链**

```powershell
$ ./gxchain-prod.sh start
```

**停止公信链**

```powershell
$ ./gxchain-prod.sh stop
```

**重启公信链**

```powershell
$ ./gxchain-prod.sh restart
```

**查询公信链状态**

```
$ ./gxchain-prod.sh status
```