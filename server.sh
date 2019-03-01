#!/bin/sh
PID_DIR=/tmp
if [ $UID != 0 ]; then
   echo Please run as root.
elif [ "$1" = "stop" ]; then
   echo Stopping servers...
   if [ -r $PID_DIR/nuttcp.pid ]; then kill `cat $PID_DIR/nuttcp.pid`; rm $PID_DIR/nuttcp.pid; fi
   if [ -r $PID_DIR/iperf3.pid ]; then kill `cat $PID_DIR/iperf3.pid`; rm $PID_DIR/iperf3.pid; fi
else
   echo Starting servers...
   firewall-cmd --add-port 5000/tcp --add-port 5000/udp --add-port 5001/tcp --add-port 5001/udp --add-port 5201/tcp --add-port 5201/udp
   /usr/bin/nuttcp -S &
   echo $! > $PID_DIR/nuttcp.pid
   /usr/bin/iperf3 -s -D -I $PID_DIR/iperf.pid
fi
