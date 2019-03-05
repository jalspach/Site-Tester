#!/bin/bash

# Defaults, override in config.ini
log_dir=$HOME/Site-Tester/Results
log_prefix=""
site=site
sites=site:Default_Site
iperf_retries=3
#iperf_opts="-Z"
iperf_opts="-f m -O 2 -t 20 -P 10"
iperf_target="-b 100M"
iperf_tcp_forward=1
iperf_tcp_reverse=1
iperf_udp_forward=1
iperf_udp_reverse=1
nuttcp_retries=3
#nuttcp_opts="-xt"
nuttcp_opts=
speedtest_opts=

# Defaults, override with command line options
CFG_FILE=`dirname $0`/config.ini
BATCH=1
VERBOSE=0

#BASH_INI_PARSER_DEBUG=1 

function die() { echo "$*" 1>&2 ; exit 1; }
function verbose() { [[ $VERBOSE = 0 ]] || echo "$*" 1>&2 ; }
function log() { LOG_FILE=$1; shift; echo "$*" >> $LOG_FILE ; }

while getopts "bc:hr:l:s:v" opt; do
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
    v ) # site
      VERBOSE=1
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

declare -A SITE_ARRAY
for my_site in ${sites[@]}; do
   IFS=: read -r my_key my_value <<< "$my_site"
   SITE_ARRAY[$my_key]="$my_value"
done

if [ ! -z "$OPT_LOG_DIR" ]; then
   log_dir=$OPT_LOG_DIR
fi

if [ ! -z "$OPT_RETRIES" ]; then
   iperf_retries=$OPT_RETRIES
   speedtest_retries=$OPT_RETRIES
   nuttcp_retries=$OPT_RETRIES
fi

if [ ! -z "$OPT_SITE" ]; then
   site=$OPT_SITE
fi

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
#			log_prefix="PreInstall-"
#			break
#			;;
#		n|N)
#			echo "We will NOT these tests as pre installation test results"
#			log_prefix=""
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

if [ ! -z "$site" ]; then
   SITE_CODE=$site
   SITE_NAME=${SITE_ARRAY[$site]}
else
   SITE_CODE="site"
   SITE_NAME="Default_Site"
fi
LOG_LOCATION=$log_dir/$SITE_CODE
verbose "Creating folder to store results: $LOG_LOCATION"
mkdir -p ${LOG_LOCATION} || die "Can't create log directory: $LOG_LOCATION"
verbose "Each test should take less than a min to complete."
NOW=$(date +%F_%H-%M-%S)


log $LOG_LOCATION/log-${NOW}.txt "Starting tests at ...$(date)"
verbose "Starting tests at ...$(date)"

t=1
# Test template to copy as needed
# echo ""
# copy this test as needed for various services and locations or, better yet, run all netcat tests to a single log file.
# echo "Test $t (NETCAT to system1) in progress"
#   ((t++))
#   for (( r=0; r<$iperf_retries; r++ )); do
# /bin/netcat -xv iperf.shastacoe.net 80 > ${LOG_LOCATION}/${log_prefix}${SITE_CODE}_netcat-2-SCOE80.${NOW}.log
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
## get length of $iperf_hosts array
len=${#iperf_hosts[@]}
 
## Loop through iperf servers
for (( i=0; i<$len; i++ )); do
   iperf_host=${iperf_hosts[$i]}
   if [ $iperf_tcp_forward -ne 0 ]; then
      echo "Test $t (Iperf to $iperf_host TCP Forward) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
      ((t++))
      for (( r=$iperf_retries; r>0; r-- )); do
         /usr/bin/iperf3 -c $iperf_host $iperf_opts $iperf_target -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-$iperf_host.iperf-tcp-forward.${NOW}.log
         if [ $? -eq 0 ]
         then
            echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
            break
         else
            echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
            sleep 4
         fi
      done
   fi
   if [ $iperf_tcp_reverse -ne 0 ]; then
      echo "Test $t (Iperf to $iperf_host TCP Reverse) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
      ((t++))
      for (( r=$iperf_retries; r>0; r-- )); do
      /usr/bin/iperf3 -c $iperf_host $iperf_opts $iperf_target -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-$iperf_host.iperf-tcp-reverse.${NOW}.log
         if [ $? -eq 0 ]
         then
            echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
            break
         else
            echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
            sleep 4
         fi
      done
   fi
   if [ $iperf_udp_forward -ne 0 ]; then
      echo "Test $t (Iperf to $iperf_host UDP Forward) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
      ((t++))
      for (( r=$iperf_retries; r>0; r-- )); do
      /usr/bin/iperf3 -c $iperf_host $iperf_opts $iperf_target -u -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-$iperf_host.iperf-udp-forward.${NOW}.log
         if [ $? -eq 0 ]
         then
            echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
            break
         else
            echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
            sleep 4
         fi
      done
   fi
   if [ $iperf_udp_reverse -ne 0 ]; then
      echo "Test $t (Iperf to $iperf_host UDP Reverse) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
      ((t++))
      for (( r=$iperf_retries; r>0; r-- )); do
      /usr/bin/iperf3 -c $iperf_host $iperf_opts $iperf_target -u -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-$iperf_host.iperf-udp-reverse.${NOW}.log
         if [ $? -eq 0 ]
         then
            echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
            break
         else
            echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
            sleep 4
         fi
      done
   fi
done
## get length of $speedtest_hosts array
len=${#speedtest_hosts[@]}
 
## Loop through speedtest servers
for (( i=0; i<$len; i++ )); do
   speedtest_host=${speedtest_hosts[$i]}
   echo "Test $t (Speedtest to $speedtest_host) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=$speedtest_retries; r>0; r-- )); do
   /usr/bin/speedtest $nuttcp_opts --server $speedtest_host | tee -a ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-speedtest_hostsspeedtest_host.speedtest.${NOW}.log
   /usr/bin/speedtest $nuttcp_opts --server $speedtest_host --csv >> ${LOG_LOCATION}/${log_prefix}speedtest.csv
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
## get length of $nuttcp_hosts array
len=${#nuttcp_hosts[@]}
 
## Loop through nuttcp servers
for (( i=0; i<$len; i++ )); do
   nuttcp_host=${nuttcp_hosts[$i]}
   echo "Test $t (NUTTCP to $nuttcp_host) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
   ((t++))
   for (( r=$nuttcp_retries; r>0; r-- )); do
   /usr/bin/nuttcp $nuttcp_opts $nuttcp_host > ${LOG_LOCATION}/${log_prefix}${SITE_CODE}-2-$nuttcp_host.nuttcp.${NOW}.log
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

#copy this test as needed for various services and locations or, better yet, run all netcat tests to a single log file.
#echo "Test $t (nmap to system1) in progress" | tee -a $LOG_LOCATION/log-${NOW}.txt
#   ((t++))
#   for (( r=0; r<$RETRIES; r++ )); do
#/usr/bin/nmap -sT -v -p 80 iperf.shastacoe.net -oG ${LOG_LOCATION}/${log_prefix}${SITE_CODE}_nmap-2-SCOE80.${NOW}.log
#	if [ $? -eq 0 ]
#	then
#		echo "Test completed as expected" | tee -a $LOG_LOCATION/log-${NOW}.txt
#		break
#	else
#		echo "Test did NOT complete as expected. Making $r more attempts" | tee -a $LOG_LOCATION/log-${NOW}.txt
#		sleep 4
#	fi
#done
log $LOG_LOCATION/log-${NOW}.txt "Testing complete at ...$(date)"
verbose "Testing complete at ...$(date)"
verbose "Logs available here: $LOG_LOCATION"
# echo "Copy files to accessable storage"
# svn ${LOG_LOCATION}/* ${REMOTE_LOCATION}/${SITE_CODE}/
# echo "finished copying files to remote accessable storage"
exit 0
