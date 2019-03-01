#!/bin/sh
if [ $UID != 0 ]; then
   echo Please run as root.
else
   PID_DIR=/tmp
   firewall-cmd --add-port 5001/tcp --add-port 5001/udp --add-port 5201/tcp --add-port 5201/udp
   /usr/bin/nuttcp -S &
   echo $! > $PID_DIR/nuttcp.pid
   /usr/bin/iperf3 -s -D -I $PID_DIR/iperf.pid
fi
