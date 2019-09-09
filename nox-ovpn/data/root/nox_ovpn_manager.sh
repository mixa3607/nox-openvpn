#!/bin/sh
ACTION=$1
PARAM1=$2

InstanceId="$PARAM1"
ConfigsFolder="/root/nox_ovpn_configs/"

if [ -z "$PARAM1" ]
then
	echo "using: <script>.sh <command> <id>"
	exit 1
fi

#check id
if [ "$InstanceId" -lt 9 ] || [ "$InstanceId" -gt 14 ]
then
	echo "Param must be in range from 9 to 14"
	exit 1
fi


ConfigFile="${ConfigsFolder}${InstanceId}.ovpn"
ConfigAuth="${ConfigsFolder}${InstanceId}.auth"
InstancePidFile="${ConfigsFolder}${InstanceId}.pid"
InstanceLogFile="${ConfigsFolder}${InstanceId}.log"
OvpnIfName="nox_ovpn_${InstanceId}"
ManagamentPort=$(( 60000 + $InstanceId ))

StartOvpn() {
	if ! [ -f "$ConfigFile" ]
	then
		echo "Config $ConfigFile not exist!"
		exit 2
	fi
	if [ -f "$ConfigAuth" ]
	then
		echo "Auth file $ConfigAuth is exist"
		openvpn --config "$ConfigFile" --auth-user-pass "$ConfigAuth" --route-nopull --writepid "$InstancePidFile" --log "$InstanceLogFile" --dev "$OvpnIfName" --dev-type tun --daemon #--management 127.0.0.1 $ManagamentPort 
	else
		openvpn --config "$ConfigFile" --daemon --route-nopull --writepid "$InstancePidFile" --log "$InstanceLogFile" --dev "$OvpnIfName" --dev-type tun #--management "localhost $ManagamentPort" 
	fi
	echo "openvpn instance started." # Management console available on $ManagamentPort local port"
}


if [ "$ACTION" = "help" ] ; then
	echo "Using: $0 (start|stop|restart|status|log) instance_id [tail]
	Optionally arg 'tail' - print openvpn log to stdin.
	All configs placed in $ConfigsFolder folder
	Naming 	<num>.ovpn	- main config file
			<num>.auth	- file with login and pass (not required)"
		
#start openvpn instance
elif [ "$ACTION" = "start" ] ; then
	StartOvpn
#print status
elif [ "$ACTION" = "status" ] ; then
	if kill -0 $(cat "$InstancePidFile") > /dev/null 2>&1
	then
		echo "Instance with id $InstanceId is running"
	else 
		echo "Instance with id $InstanceId is NOT running"
	fi
	
#print log
elif [ "$ACTION" = "log" ] ; then
	if ! kill -0 $(cat "$InstancePidFile") > /dev/null 2>&1
	then
		echo "Instance with id $InstanceId is NOT running"
	fi
	cat "$InstanceLogFile"
	
#NEED BUILD OpenVpn WITH FLAG
#managment console
#elif [ "$ACTION" = "console" ] ; then
#	if kill -0 $(cat "$InstancePidFile") > /dev/null 2>&1
#	then
#		telnet 127.0.0.1 $ManagamentPort
#	else 
#		echo "Instance with id $InstanceId is NOT running"
#	fi
elif [ "$ACTION" = "stop" ] ; then
	if kill $(cat "$InstancePidFile") > /dev/null 2>&1
	then
		echo "Instance with id $InstanceId is stopped"
	else
		echo "Problem with stopping. Maybe instance not runned?"
	fi

elif [ "$ACTION" = "restart" ] ; then
	echo "ovpn stop"
	$0 stop $InstanceId
	sleep 1s
	echo "ovpn start"
	$0 start $InstanceId
	
else
	echo "No command $ACTION"
fi

if [ "$3" = "tail" ]
then 
	echo "press ctrl+^c for close"
	tail -f "$InstanceLogFile"
fi
