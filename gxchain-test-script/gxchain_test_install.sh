#!/bin/bash
# https://docs.gxchain.org/zh/guide/testnet.html
#set -x
echo "########################################################################"
echo "# GXChain test node install script On Ubuntu 16.04 4.4.0-117-generic"
echo "# @author wangwei"
echo "# @date   20181108"
echo "########################################################################"

# config startup parameters
WORKSPACE_PATH=/mydata
GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json
DATA_DIR=$WORKSPACE_PATH/testnet_node
RPC_ENDPOINT="0.0.0.0:28090"
P2P_ENDPOINT="0.0.0.0:9999"
SEED_NODES='["testnet.gxchain.org:6789"]'

# update & install package
sudo apt-get install ntp
apt-get update
apt-get install software-properties-common
add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install libstdc++-7-dev

# enter workspace
cd $WORKSPACE_PATH

# download lastest testnet
curl 'https://raw.githubusercontent.com/gxchain/gxb-core/dev_master/script/gxchain_testnet_install.sh' | bash

# delete tar.gz file
rm -rf gxb_ubuntu_*.*.*.testnet.tar.gz

# download testnet genesis.json
wget http://gxb-package.oss-cn-hangzhou.aliyuncs.com/gxb-core/genesis/testnet-genesis.json -O $GENESIS_FILE_PATH

# start testnet node
CMD="$WORKSPACE_PATH/programs/witness_node/witness_node --data-dir=$DATA_DIR --rpc-endpoint=$RPC_ENDPOINT --p2p-endpoint=$P2P_ENDPOINT --seed-nodes=$SEED_NODES --genesis-json $GENESIS_FILE_PATH"

setsid $CMD >/dev/null 2>&1 < /dev/null &

echo "Check block sync progress. Usage: tail -f $WORKSPACE_PATH/testnet_node/logs/witness.log"


