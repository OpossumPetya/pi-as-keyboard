#!/bin/bash

case "$1" in
  start)
    echo "Starting script"
    perl /home/pi/piclient/clientd.pl
    ;;
  stop)
    echo "Stopping script"
    kill -KILL $(pidof perl)
    rm -f /home/pi/piclient/client.err
    rm -f /home/pi/piclient/client.log
    rm -f /home/pi/piclient/client.pid
    ;;
  *)
    echo "Usage: /home/pi/piclient/controller.sh {start|stop}"
    exit 1
    ;;
esac

exit 0
