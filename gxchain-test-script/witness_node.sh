#!/bin/bash
# https://github.com/gxchain/gxb-core/wiki/for_exchanges_cn
# ----------------------------------------------------------
# GXChain witness node scirpt ! 
# ----------------------------------------------------------
#set -x

# config startup parameters
CMD_USER=gxchainuser
WORKSPACE_PATH=/mydata
DATA_DIR=$WORKSPACE_PATH/testnet_node
PROGRAMS_DIR=$WORKSPACE_PATH/programs
GENESIS_FILE_PATH=$WORKSPACE_PATH/genesis.json

witness_node_pid() {
  echo `pgrep witness_node`
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
      echo -n -e "\nwaiting for processes to exit";
      sleep 1
      let count=$count+1;
    done
  else
    echo "GXChain witness node not running"
  fi

  return 0
}

case $1 in
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
    echo "GXChain witness node is running with pid: $pid"
  else
    echo "GXChain witness node is not running"
  fi
;;
esac
exit 0


