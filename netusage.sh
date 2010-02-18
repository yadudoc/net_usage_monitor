#!/bin/bash
#                                  Filename : netusage.sh
#
# assume that the net usage is monitored only in SHAJI-PC_Network
# debugging stuff is not quite ready yet 

debug=/dev/null ;
new_session=1;
in_between_session=0

while getopts "ds:" flag
do 
    if [ "$flag" == "d" ]
    then
	debug=./debug_info ;
    elif [ "$flag" == "s" ]
    then 
	if [ "$OPTARG" == "0" ] || [ "$OPTARG" == "1" ]
	then
	new_session="$OPTARG";
	else 
	    echo "Error: OPTARG for new_session parameter out of expected range " >> debug ;
	    exit 1;
	fi;
    elif [ "$flag" == "?" ]
    then 
	exit 1;
    fi 
done ;

echo "New session value $new_session " >> debug ;
echo "debug set/reset   $debug" >> debug ;


# daemon section begins
while true ;
do 

# check if you are on the n/w else sleep 
iwconfig wlan0 | grep "SHAJI-PC_Network" > /dev/null;

if [ $? -eq 0 ] ;
then 
    echo " In shaji network.... going to monitor usage "`date` >> debug ;
    a=`cat /proc/net/dev | grep wlan0` ;
    echo "$a"|cut --bytes=8- > a.txt ;

    if [ ! -f parse ];
    then
	echo "Error: parsing routine missing ";
	exit 1;
    fi;
    
    line1=`date` ;
    line2=` cat a.txt | ./parse ` ;
    last_ref_min=`date +%M --reference=./log` ;
    last_ref_hour=`date +%H --reference=./log` ;
    now_min=`date +%M`;
    now_hour=`date +%H`;
    
    # stop logging if  2 AM < now < 8 AM    	
    if [ "$now_hour" -gt 2 ] && [ "$now_hour" -lt 8 ] ;
    then 
	echo "session closed ( 2 AM - 8 AM ) " >> log ;
	sleep 1h ;
    fi;
	
    # for new session make new section in log
    if [ "$new_session" -eq 1 ]; 
    then
	echo "new session started " ;
	now=`date` ;
	echo -e "\nSession starting   $now" >> log;
	echo -e $line1"\t\t"$line2      >> log;
	new_session=0 ;
    elif [ "$(($now_min-$last_ref_min))" -lt 3 ] ;
    then	
        # if an update was made in the past 2 mins remove that and
	# replace with the newest update.
	echo "Updating the log " >> debug ;
	sed '$d'<log > temp ; mv temp log ;
	echo -e $line1"\t\t"$line2>>log;
    else
	# update was not made in the past 2 mins so add another 
       	# update to end of current session.
	echo "Updating the log " >> debug ;
	echo -e $line1"\t\t"$line2" P.S verify ">>log;
    fi
    sleep 1m ;
    in_between_session=1 ;

else
    # not connected via shaji n/w or lost conn 
    # if we were in between an active session write session terminated
    # out to the log 
    if [ "$in_between_session" -eq 1 ]
    then
	
	echo "Session terminated at "`date` >> log ;
	in_between_session=0 ;
    fi
    
    # reset new_session to 1 and wait 
    echo "Error: Not in Shaji-PC-network (waiting...) " >> debug
    new_session=1;
    sleep 1m;    
fi 

done ;



