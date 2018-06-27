#!/bin/sh
clear

echo "This test script will run prescribed tests from this box to various places on the network. It will capture the log files for later use."

echo ""
read -p "Is this a pretest? ( Y/N ) " USER_PRETEST
echo ""
while :
do
	case $USER_PRETEST in
		y|Y)
			echo "We will flag these as pre installation test results"
			PRETEST="PreInstall-"
			break
			;;
		n|N)
			echo "We will NOT these tests as pre installation test results"
			PRETEST=""
			break
			;;
		*)
			echo "Please re-run the script and choose Y or N"
			exit 1
			;;
	esac
done
echo ""
echo ""
read -p "Enter the site code you are running the test from. Choose from MI, SM, PA, RO, AM, LV, BC, MV, TR or SCOE: " USER_SITE_CODE
echo ""
while :
do
	case $USER_SITE_CODE in
		mi|MI)
			echo "Logging tests from Mistletoe"
			SITE_CODE="MI"
			SITE_NAME="Mistletoe"
			break
			;;
		"do"|DO)
			echo "Logging tests from Mistletoe"
			SITE_CODE="MI"
			SITE_NAME="Mistletoe"
			break
			;;
		sm|SM)
			echo "Logging tests from Shasta Meadows"
			SITE_CODE="SM"
			SITE_NAME="ShastaMeadows"
			break
			;;
		pa|PA)
			echo "Logging tests from Parsons"
			SITE_CODE="PA"
			SITE_NAME="Parsons"
			break
			;;
		ro|RO)
			echo "Logging tests from Rother"
			SITE_CODE="RO"
			SITE_NAME="Rother"
			break
			;;
		am|AM)
			echo "Logging tests from Alta Mesa"
			SITE_CODE="AM"
			SITE_NAME="AltaMesa"
			break
			;;
		lv|LV)
			echo "Logging tests from Lassen View"
			SITE_CODE="LV"
			SITE_NAME="LassenView"
			break
			;;
		bc|BC)
			echo "Logging tests from Boulder Creek"
			SITE_CODE="BC"
			SITE_NAME="BoulderCreek"
			break
			;;
		"mv"|MV)
			echo "Logging tests from Monte Vista"
			SITE_CODE="MV"
			SITE_NAME="MonteVista"
			break
			;;
		tr|TR)
			echo "Logging tests from Transportation"
			SITE_CODE="TR"
			SITE_NAME="Transportation"
			break
			;;
		scoe|SCOE)
			echo "logging tests from SCOE Headend"
			SITE_CODE="SCOE"
			SITE_NAME="SCOEHeadend"
			break
			;;
		*)
			echo "That is not a valid entry. Please rerun the script and use MI, SM, PA, RO, AM, LV, BC, MV, TR or SCOE"
			exit 2
			;;
	esac
done
LOG_LOCATION=$HOME/EESD-Test_Results/${SITE_NAME}/
echo ""
echo ""
echo "Creating folder to store results"
echo $LOG_LOCATION
mkdir -p ${LOG_LOCATION}
echo ""
echo ""
echo "Test suite should take a min or so to complete"
echo ""
echo ""
NOW=$(date +%F_%H-%M-%S)
echo "Starting 11 tests at ...$(date)"
echo ""
echo "Test 1 (Iperf to SCOE) in progress"
for i in 5 4 3 2 1
do
	/usr/bin/iperf3 -c iperf.shastacoe.net -V -Z -T ${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}-2-SCOE.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 2 (Iperf to SCOE UDP) in progress"
ATTEMPT=5
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.shastacoe.net -V -u -b 10M -Z -T ${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}-2-SCOE_UDP.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 3 (Iperf to HE) in progress"
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.he.net -V -Z -T${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}-2-HE.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test  as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 4 (Iperf to HE UDP) in progress"
ATTEMPT=5
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.he.net -V -u -b 10M -Z -T ${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}-2-HE_UDP.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 5 (Iperf to SCOE Reverse) in progress"
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.shastacoe.net -V -Z -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}_reverse-2-SCOE.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 6 (Iperf to SCOE UDP Reverse) in progress"
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.shastacoe.net -V -u -b 10M -Z -R -T ${SITE_CODE} --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}_reverse-2-SCOE_UDP.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 7 (Iperf to HE Reverse) in progress"
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.he.net -V -Z -R --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}_reverse-2-HE.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 8 (Iperf to HE reverse UDP) in progress"
for i in 5 4 3 2 1
do
/usr/bin/iperf3 -c iperf.he.net -V -u -b 10M -Z -R --logfile ${LOG_LOCATION}${PRETEST}${SITE_NAME}_reverse-2-HE_UDP.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo ""
echo "Test 9 (Speedtest to Chico) in progress"
for i in 5 4 3 2 1
do
/usr/bin/speedtest --server 5411 > ${LOG_LOCATION}${PRETEST}${SITE_NAME}_Speedtest-2-5411.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo "Test 10 (NUTTCP to SCOE) in progress"
for i in 5 4 3 2 1
do
/usr/bin/nuttcp -xt iperf.shastacoe.net > ${LOG_LOCATION}${PRETEST}${SITE_NAME}_nuttcp-2-SCOE.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
# copy this test as needed for various services and locations or, better yet, run all netcat tests to a single log file.
echo "Test 11 (NETCAT to system1) in progress"
for i in 5 4 3 2 1
do
/bin/netcat -xv iperf.shastacoe.net 80 > ${LOG_LOCATION}${PRETEST}${SITE_NAME}_netcat-2-SCOE80.${NOW}.log
	if [ $? -eq 0 ]
	then
		echo "Test completed as expected"
		break
	else
		echo "Test did NOT complete as expected. Making $i more attempts"
		sleep 4
	fi
done
echo "Testing complete at ...$(date)"
echo ""
# echo "Copy files to accessable storage"
# svn ${LOG_LOCATION}/* ${REMOTE_LOCATION}/${SITE_NAME}/
# echo "finished copying files to remote accessable storage"
exit 0
