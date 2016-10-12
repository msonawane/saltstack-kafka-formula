#!/bin/sh
#
# chkconfig: 345 99 01
# description: Kafka
#
# File : Kafka
#
# Description: Starts and stops the Kafka server
#

KAFKA_HOME={{workdir}}
KAFKA_USER={{user}}

mkdir -p /var/log/kafka
chown -R {{user}} /var/log/kafka
# See how we were called.
case "$1" in

  start)
    echo -n "Starting Kafka:"
     /bin/su  $KAFKA_USER -c "nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /var/log/kafka/server.out 2> /var/log/kafka/server.err &"
    echo " done."
    exit 0
    ;;

  stop)
    echo -n "Stopping Kafka: "
     /bin/su $KAFKA_USER -c "ps -ef | grep kafka.Kafka | grep -v grep | awk '{print \$2}' | xargs -r kill"
    echo " done."
    exit 0
    ;;
  hardstop)
    echo -n "Stopping (hard) Kafka: "
     /bin/su $KAFKA_USER -c "ps -ef | grep kafka.Kafka | grep -v grep | awk '{print \$2}' | xargs -r kill -9"
    echo " done."
    exit 0
    ;;

  status)
    c_pid=`ps -ef | grep kafka.Kafka | grep -v grep | awk '{print $2}'`
    if [ "$c_pid" = "" ] ; then
      echo "Stopped"
      exit 3
    else
      echo "Running $c_pid"
      exit 0
    fi
    ;;

  restart)
    $0 stop && $0 start
    ;;

  *)
    echo "Usage: kafka {start|stop|hardstop|status|restart}"
    exit 1
    ;;

esac

