#!/bin/bash

LOG_DIR=$HOME/Site-Tester/Results/
CFG_FILE=`dirname $0`/config.ini
RETRIES=5
SITE=site
#IPERF_OPTS="-Z"
IPERF_OPTS="-f m -O 2 -t 20 -P 10"
IPERF_TARGET="-b 100M"
#NUTTCP_OPTS="-xt"

while getopts "bc:hr:l:s:" opt; do
  case ${opt} in
    b ) # batch mode
      BATCH=1
      ;;
    c ) # config location
      CFG_FILE=$OPTARG
      ;;
    l ) # log location
      OPT_LOG_DIR=$OPTARG
      ;;
    r ) # retries
      OPT_RETRIES=$OPTARG
      ;;
    s ) # site
      OPT_SITE=$OPTARG
      ;;
    h|\? )
      echo "Usage: $0 [-h] [-b]"
      exit
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit
      ;;
  esac
done

if [ -r $CFG_FILE ]; then
   source `dirname $0`/bash-ini-parser
   cfg_parser $CFG_FILE
   cfg_section_global
   cfg_section_client
fi

if [ ! -z "$OPT_LOG_DIR" ]; then
   LOG_DIR=$OPT_LOG_DIR
elif [ ! -z "$retries" ]; then
   LOG_DIR=$logdir
fi

if [ ! -z "$OPT_RETRIES" ]; then
   RETRIES=$OPT_RETRIES
elif [ ! -z "$retries" ]; then
   RETRIES=$retries
fi

if [ ! -z "$OPT_SITE" ]; then
   SITE=$OPT_SITE
elif [ ! -z "$site" ]; then
   SITE=$site
fi
#exit
#clear

#echo "This test script will run prescribed tests from this box to various places on the network. It will capture the log files for later use."
#
#echo ""
#read -p "Is this a pretest? ( Y/N ) " USER_PRETEST
#echo ""
#while :
#do
#	case $USER_PRETEST in
#		y|Y)
#			echo "We will flag these as pre installation test results"
#			PRETEST="PreInstall-"
#			break
#			;;
#		n|N)
#			echo "We will NOT these tests as pre installation test results"
#			PRETEST=""
#			break
#			;;
#		*)
#			echo "Please re-run the script and choose Y or N"
#			exit 1
#			;;
#	esac
#done
#echo ""
#echo ""
#read -p "Enter the site code you are running the test from. Choose from MI, SM, PA, RO, AM, LV, BC, MV, TR or SCOE: " USER_SITE_CODE
#echo ""
#while :
#do
#	case $USER_SITE_CODE in
#		scoe|SCOE)
#			echo "logging tests from SCOE Headend"
#			SITE_CODE="SCOE"
#			SITE_NAME="SCOEHeadend"
#			break
#			;;
#		*)
#			echo "That is not a valid entry. Please rerun the script and use MI, SM, PA, RO, AM, LV, BC, MV, TR or SCOE"
#			exit 2
#			;;
#	esac
#done

# flock to prevent multiple simultaneous runs
exec 55<$0;
if ! flock -n -x 55; then
echo "An instance of this script is already running.";
exit 1
fi

echo ""
echo ""
LOG_LOCATION=$LOG_DIR/$SITE/
PRETEST=""
SITE_CODE=$SITE
SITE_NAME=$SITE
echo "Creating folder to store results"
echo $LOG_LOCATION
mkdir -p ${LOG_LOCATION}
echo ""
echo ""
echo "Test suite should take a min or so to complete"
echo ""
echo ""
NOW=$(date +%F_%H-%M-%S)


echo "Starting tests at ...$(date)" | tee -a $LOG_LOCATION/log-${NOW}.txt
t=1
# Test template to copy as needed
# echo ""
# copy this test as needed for various services and locations or, better yet, run all netcat tests to a single log file.
# echo "Test $t (NETCAT to system1) in progress"
#   ((t++))
#   for (( r=0; r<$RETRIES; r++ )); do 
# /bin/netcat -xv iperf.shastacoe.net 80 > ${LOG_LOCATION}/${PRETEST}${SITE_NAME}_netcat-2-SCOE80.${NOW}.log
# 	if [ $? -eq 0 ]
# 	then
# 		echo "Test completed as expected"
# 		break
# 	else
# 		echo "Test did NOT complete as expected. Making $r more attempts"
# 		sleep 4
# 	fi
# done
echo ""
## get length of $iperf array
len=${#iperf[@]}
 
## Loop through iperf servers
for (( i=0; i<$len; i++ )); do 
   iperf_host=${iperf[$i]}
   echo "Test $t (Iperf to $iperf_host) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   	/usr/bin/iperf3 -c $iperf_host $IPERF_OPTS $IPERF_TARGET -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$iperf_host.iperf.${NOW}.log
   	if [ $? -eq 0 ]
   	then
   		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		break
   	else
   		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		sleep 4
   	fi
   done
   echo ""
   echo "Test $t (Iperf to $iperf_host Reverse) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   /usr/bin/iperf3 -c $iperf_host $IPERF_OPTS $IPERF_TARGET -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$iperf_host.iperf-reverse.${NOW}.log
   	if [ $? -eq 0 ]
   	then
   		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		break
   	else
   		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		sleep 4
   	fi
   done
   echo ""
   echo "Test $t (Iperf to $iperf_host UDP) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   /usr/bin/iperf3 -c $iperf_host $IPERF_OPTS $IPERF_TARGET -u -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$iperf_host.iperf-udp.${NOW}.log
   	if [ $? -eq 0 ]
   	then
   		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		break
   	else
   		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		sleep 4
   	fi
   done
   echo ""
   echo "Test $t (Iperf to $iperf_host UDP Reverse) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   /usr/bin/iperf3 -c $iperf_host $IPERF_OPTS $IPERF_TARGET -u -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$iperf_host.iperf-udp-reverse.${NOW}.log
   	if [ $? -eq 0 ]
   	then
   		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		break
   	else
   		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		sleep 4
   	fi
   done
done
## get length of $speedtest array
len=${#speedtest[@]}
 
## Loop through speedtest servers
for (( i=0; i<$len; i++ )); do 
   speedtest_host=${speedtest[$i]}
   echo ""
   echo "Test $t (Speedtest to $speedtest_host) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   /usr/bin/speedtest --server $speedtest_host | tee -a ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$speedtest_host.speedtest.${NOW}.log
   /usr/bin/speedtest --server $speedtest_host --csv >> ${LOG_LOCATION}/${PRETEST}speedtest.csv
   	if [ $? -eq 0 ]
   	then
   		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		break
   	else
   		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
   		sleep 4
   	fi
   done
done
## get length of $nuttcp array
len=${#nuttcp[@]}
 
## Loop through nuttcp servers
for (( i=0; i<$len; i++ )); do 
   nuttcp_host=${nuttcp[$i]}
   echo ""
   echo "Test $t (NUTTCP to $nuttcp_host) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=0; r<$RETRIES; r++ )); do 
   /usr/bin/nuttcp $NUTTCP_OPTS $nuttcp_host > ${LOG_LOCATION}/${PRETEST}${SITE_NAME}-2-$nuttcp_host.nuttcp.${NOW}.log
      if [ $? -eq 0 ]
      then
         echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
         break
      else
         echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
         sleep 4
      fi
   done
done

#echo ""
#copy this test as needed for various services and locations or, better yet, run all netcat tests to a single log file.
#echo "Test $t (nmap to system1) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
#   ((t++))
#   for (( r=0; r<$RETRIES; r++ )); do 
#/usr/bin/nmap -sT -v -p 80 iperf.shastacoe.net -oG ${LOG_LOCATION}/${PRETEST}${SITE_NAME}_nmap-2-SCOE80.${NOW}.log
#	if [ $? -eq 0 ]
#	then
#		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
#		break
#	else
#		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
#		sleep 4
#	fi
#done
#echo ""
echo "Testing complete at ...$(date)" | tee -a $LOG_LOCATION/log-${NOW}.txt
echo ""
echo "Logs available here: $LOG_LOCATION"
# echo "Copy files to accessable storage"
# svn ${LOG_LOCATION}/* ${REMOTE_LOCATION}/${SITE_NAME}/
# echo "finished copying files to remote accessable storage"
exit 0
