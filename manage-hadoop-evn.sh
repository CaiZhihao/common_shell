#!/bin/bash

HADOOP_HOME=/home/hadoop/hadoop-1.2.1
ZK_HOME=/home/hadoop/zookeeper-3.4.5
STORM_HOME=/home/hadoop/apache-storm-0.9.3

nodes=(
master
slave1
slave2
)

startAll(){
    hadoopStart
    zk start
}

stopAll(){
    hadoopStop
    zk stop
}

hadoopStart(){
    $HADOOP_HOME/bin/start-all.sh
}

hadoopStop(){
    $HADOOP_HOME/bin/stop-all.sh
}

zk(){
    for node in ${nodes[@]}
    do
        ssh $node $ZK_HOME/bin/zkServer.sh $1
    done
}

case $1 in
    start)
        case $2 in 
            hadoop)
                hadoopStart
            ;;
             zookeeper)
                zk start
            ;;
             all)
                startAll
            ;;
            *)
                echo "do not find component called $2" 
            ;;
        esac
    ;;
    stop)
         case $2 in
            hadoop)
                hadoopStop
            ;;
             zookeeper)
                zk stop
            ;;
             all)
                stopAll
            ;;
            *)
                echo "do not find component called $2"
            ;;
        esac
    ;;
    *)
        echo "USAGE:$0 [start|stop] component" 
    ;;
esac
