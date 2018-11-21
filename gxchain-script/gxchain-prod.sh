#!/bin/bash
#--------------------------------------------------------------------"
# GXChain product node install script On Ubuntu 16.04 4.4.0-117-generic"
# @author https://wangwei.one"
# @date   20181108"
#--------------------------------------------------------------------"
# https://docs.gxchain.org/zh/guide/witness.html

#set -x
# gxchain user
CMD_USER=gxchainuser

# port config
RPC_ENDPOINT="127.0.0.1:28090"
P2P_ENDPOINT="0.0.0.0:9999"
#SEED_NODES='["testnet.gxchain.org:6789"]'

# workspace config
WORKSPACE_PATH=/mydata
GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json
DATA_DIR=$WORKSPACE_PATH/trusted_node
PROGRAMS_DIR=$WORKSPACE_PATH/programs

# witness config
WITNESS_ID="1.6.1"
PUBLICK_KEY="GXC6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"
PRIVATE_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"

RED="\033[0;31m"
GREEN="\033[0;32m"
NO_COLOR="\033[0m"

install(){
	echo "Starting GXChain install ... "
	
	sudo apt-get install ntp
    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt-get update
    sudo apt-get install libstdc++-7-dev
    
	# enter workspace
	cd $WORKSPACE_PATH

	# download lastest release
	curl 'https://raw.githubusercontent.com/gxchain/gxb-core/dev_master/script/gxchain_install.sh' | bash

	# delete tar.gz file
	rm -rf gxb_ubuntu_*.*.*.tar.gz

	chown -R $CMD_USER:$CMD_USER $PROGRAMS_DIR

	echo -e "$GREEN GXChain install Finished. $NO_COLOR"

	return 0
}

sync_block() {
	echo "Starting GXChain sync block ... "
	
	CMD="$WORKSPACE_PATH/programs/witness_node/witness_node --data-dir='$DATA_DIR' -w "\"$WITNESS_ID\"" --private-key '["\"$PUBLICK_KEY\"","\"$PRIVATE_KEY\""]' "

	/bin/su - -c "setsid $CMD >/dev/null 2>&1 < /dev/null &" $CMD_USER

	echo "Check block sync progress. Usage: tail -f $WORKSPACE_PATH/trusted_node/logs/witness.log"

	return 0
}

gen_config(){
	echo "Starting generate config.ini ... "
	# backup config.ini
	cp $DATA_DIR/config.ini $DATA_DIR/config.ini.bak

	sed -ri "s/#\s+p2p-endpoint\s+=/p2p-endpoint=\"${P2P_ENDPOINT}\"/g;" $DATA_DIR/config.ini
	#sed -ri "s/#\s+seed-nodes\s+=/seed-nodes=${SEED_NODES}/g;" $DATA_DIR/config.ini
	sed -ri "s/#\s+rpc-endpoint\s+=/rpc-endpoint=\"${RPC_ENDPOINT}\"/g;" $DATA_DIR/config.ini
	#sed -ri "s/#\s+genesis\-json\s+=/genesis\-json=${GENESIS_FILE_PATH}/g;" $DATA_DIR/config.ini
	sed -ri "s/#\s+witness-id\s+=/witness-id=\"${WITNESS_ID}\"/g;" $DATA_DIR/config.ini
	sed -ri "s/GXC6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV/${PUBLICK_KEY}/g;" $DATA_DIR/config.ini
	sed -ri "s/5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3/${PRIVATE_KEY}/g;" $DATA_DIR/config.ini

	echo -e "$GREEN Generate config.ini Finished. $NO_COLOR"

	grep '/mydata/gxchain-prod.sh' /etc/rc.local &> /dev/null
	if [ $? != 0 ] ; then
           sed -i '/exit\s0/d' /etc/rc.local
           echo -e '/bin/sh /mydata/gxchain-prod.sh start\nexit 0' >> /etc/rc.local
        fi
	echo -e "$GREEN GXChain config start on boot Finished. $NO_COLOR"

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
    CMD="$PROGRAMS_DIR/witness_node/witness_node --data-dir='$DATA_DIR'"
    /bin/su - -c "setsid $CMD >/dev/null 2>&1 < /dev/null &" $CMD_USER
  fi
  sleep 1
  tail -n 100 $DATA_DIR/logs/witness.log
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
	  echo -n -e "GXChain witness node not running \n"
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
    echo -n -e "GXChain witness node is running with pid: $pid\n"
  else
    echo -n -e "GXChain witness node is not running\n"
  fi
;;
esac
exit 0


