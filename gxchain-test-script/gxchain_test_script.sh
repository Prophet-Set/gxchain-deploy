#!/bin/bash
# https://docs.gxchain.org/zh/guide/testnet.html
#set -x
echo "#--------------------------------------------------------------------"
echo "# GXChain test node install script On Ubuntu 16.04 4.4.0-117-generic"
echo "# @author https://wangwei.one"
echo "# @date   20181108"
echo "#--------------------------------------------------------------------"

# config startup parameters
CMD_USER=gxchainuser
RPC_ENDPOINT="0.0.0.0:28090"
P2P_ENDPOINT="0.0.0.0:9999"
SEED_NODES='["testnet.gxchain.org:6789"]'
WORKSPACE_PATH=/mydata
GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json
DATA_DIR=$WORKSPACE_PATH/testnet_node
PROGRAMS_DIR=$WORKSPACE_PATH/programs

install(){
	echo "Starting GXChain install ... "
	
	# enter workspace
	cd $WORKSPACE_PATH

	# download lastest testnet
	curl 'https://raw.githubusercontent.com/gxchain/gxb-core/dev_master/script/gxchain_testnet_install.sh' | bash

	# delete tar.gz file
	rm -rf gxb_ubuntu_*.*.*.testnet.tar.gz

	# download testnet genesis.json
	wget http://gxb-package.oss-cn-hangzhou.aliyuncs.com/gxb-core/genesis/testnet-genesis.json -O $GENESIS_FILE_PATH

	echo "GXChain install Finished ! "

	return 0
}

sync_block() {
	echo "Starting GXChain sync block ... "
	
	CMD="$WORKSPACE_PATH/programs/witness_node/witness_node --data-dir=$DATA_DIR --rpc-endpoint=$RPC_ENDPOINT --p2p-endpoint=$P2P_ENDPOINT --seed-nodes=$SEED_NODES --genesis-json $GENESIS_FILE_PATH"

	/bin/su - -c "setsid $CMD >/dev/null 2>&1 < /dev/null &" $CMD_USER

	echo "Check block sync progress. Usage: tail -f $WORKSPACE_PATH/testnet_node/logs/witness.log"

	return 0
}

gen_config(){
	echo "Starting generate config.ini ... "
	# backup config.ini
	cp $DATA_DIR/config.ini $DATA_DIR/config.ini.bak

	sed -ri "s/#\s+p2p-endpoint\s+=/p2p-endpoint='${P2P_ENDPOINT}'/g;" $DATA_DIR/config.ini
	sed -ri "s/#\s+seed-nodes\s+=/seed-nodes='${SEED_NODES}'/g;" $DATA_DIR/config.ini
	sed -ri "s/#\s+rpc-endpoint\s+=/rpc-endpoint='${RPC_ENDPOINT}'/g;" $DATA_DIR/config.ini

	echo "Generate config.ini Finished ! "

	return 0
}

witness_node_pid() {
    echo `ps aux | grep $PROGRAMS_DIR/witness_node/witness_node | grep -v grep | awk '{ print $2 }'`
    return 0
}

start() {
  pid=$(witness_node_pid)
  if [ -n "$pid" ]
  then
    echo "GXChain witness node is already running (pid: $pid)"
  else
    # Start run witness node
    echo "Starting witness node ... "
    #ulimit -n 100000
    umask 007
    /bin/su - -c "cd $PROGRAMS_DIR/witness_node  && $PROGRAMS_DIR/witness_node/witness_node --data-dir=$DATA_DIR --genesis-json $GENESIS_FILE_PATH" $CMD_USER
  fi
  
  tail -n 300 $DATA_DIR/logs/witness.log

  return 0
}

stop() {
	pid=$(witness_node_pid)
	if [ -n "$pid" ]
	then
	echo "Stoping GXChain witness node ... "
	/bin/su - -c "kill -s SIGINT $pid" $CMD_USER

	count=0;
	until [ `ps -p $pid | grep -c $pid` = '0' ]
	do
	  echo -n -e "\nwaiting for processes to exit \n ";
	  sleep 1
	  let count=$count+1;
	done
	else
	echo "GXChain witness node not running \n"
	fi
	return 0
}

case $1 in
install)
  install
;;
sync_block)
  sync_block
;;
gen_config)
  gen_config
;;  
start)
  start
;;
stop)
  stop
;;
restart)
  stop
  start
;;
status)
  pid=$(witness_node_pid)
  if [ -n "$pid" ]
  then
    echo "GXChain witness node is running with pid: $pid\n"
  else
    echo "GXChain witness node is not running\n"
  fi
;;
esac
exit 0


