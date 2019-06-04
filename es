#!/bin/sh
#chkconfig: 2345 80 05
#description: elasticsearch

case "$1" in
start)
    su es<<!
    cd /usr/local/elasticsearch
    ./bin/elasticsearch -d
!
    echo "elasticsearch startup"
    ;;  
stop)
    es_pid=`ps aux|grep elasticsearch | grep -v 'grep elasticsearch' | awk '{print $2}'`
    kill -9 $es_pid
    echo "elasticsearch stopped"
    ;;  
restart)
    es_pid=`ps aux|grep elasticsearch | grep -v 'grep elasticsearch' | awk '{print $2}'`
    kill -9 $es_pid
    echo "elasticsearch stopped"
    su es<<!
    cd /usr/local/elasticsearch
    ./bin/elasticsearch -d
!
    echo "elasticsearch startup"
    ;;  
*)
    echo "start|stop|restart"
    ;;  
esac

exit $?
