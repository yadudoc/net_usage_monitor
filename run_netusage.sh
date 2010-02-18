#!/bin/bash
#                                     Filename : run_netusage.sh 
#
# The function of this script is to run the netusage.sh script
# and to handle the situations when netusage.sh crashes, ensuring
# the consistency of the log file. 
# 

session_status=0 ;
debug=/dev/null ;

while getopts "dt" flag
do
    if [ "$flag" == "d" ]
    then
	debug=./debug_info ;
    elif [ "$flag" == "t" ]
    then
	last=`tail --lines=1 log` ;
	echo $last | grep "Session Terminated" >> log ;
	if [ ! "$?" -eq 0 ]
	then 
	    echo "Session Terminated" ;
	fi
	pkill netusage.sh ;
	exit 0;
    elif [ "$flag" == "?" ]
    then
        exit 1;
    fi
done ;

if [ ! -x "./netusage.sh" ]
then
    echo "Error: executable netusage.sh not found! " >> debug 
    exit 2;
fi

last=
flag=1;


last=`tail --lines=1 log` ;
echo $last | grep "Session Terminated" ;
if [ ! "$?" -eq 0 ]
then 
    echo "Session Terminated" >> log ;
fi


while [ flag ] 
do
    # terminate if netusage.sh exits with status 0 
    flag=0 ;
    
    `./netusage.sh $1 -s $session_status ` ;
    
    # handle case of netusage getting killed due to some random
    # -failure clear the last session update
    if [ ! "$?" -eq 0 ]
    then 
	flag=1;
	echo "Session killed at "`date` >> debug ;
	session_status=1;	    
    fi ;
    sleep 1s;
done;

exit 0 ;
