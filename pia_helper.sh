script_command=$1

if [[ -z $script_command ]]
then 
	echo "Uh oh. Nothing was passed to the script."
	exit
elif [[ $script_command != "start" ]] && [[ $1 != "stop" ]]
then
	echo "Uh oh. Script only accepts start and stop commands."
	exit
fi

# Seconds the script will wait for PIA to get an IP assigned
OPENVPN_TIMEOUT=20

# Seconds the script will wait for the external IP to match PIA IP
EXTERNAL_IP_TIMEOUT=20

# Seconds the script will wait for openvpn to shutdown
SHUTDOWN_TIMEOUT=20

# PIA openvpn state
PIA_state=$(ps -ef | grep --line-buffered pia_nw)

# PIA state
openvpn_state=$(ps -ef | grep --line-buffered pia | grep --line-buffered "openvpn --client")

# Username used to create log path dynamically
logged_in_user=$(id -un)

# log path
log_path=/Users/"$logged_in_user"/.pia_manager/log/pia_manager.log

if [[ $script_command == "start" ]]
then
	# if already running but disconnected, restart
	if [[ -z $openvpn_state ]]
	then
		# Issue a kill on the PIA Process
		ps -ef | grep --line-buffered "Private Internet Access" | grep -m 1 --line-buffered pia_nw | awk '{print $3}' | xargs kill 2>/dev/null

		# Buffer 1 second
		sleep 3

		# Wait for openvpn to shut down
		for i in $(seq 1 $SHUTDOWN_TIMEOUT)
		do
			# PIA IP. Empty string if not running
			openvpnIP=$(ps -ef | grep --line-buffered pia_manager | grep --line-buffered openvpn | sed -l 's/.*--remote //g; s/ 8080.*//g')	
			if [[ -z $openvpnIP ]]
			then
				break
			else 
				if [ $SHUTDOWN_TIMEOUT -eq $i ]
				then 
					echo "Uh oh. Shutdown timed out."
					exit
				fi
				sleep 1
			fi
		done

		# Start PIA
		open -n /Applications/Private\ Internet\ Access.app &

		# Clear the log to allow sed to read the most recent outputs of the tail command
		echo > $log_path
		tail -f $log_path | sed -n '/Connection status is CONNECTED/ q'
		echo "PIA Connected."
	else
		echo "PIA already running."
	fi
elif [[ $script_command == "stop" ]]
then
	# if running disconnected, stop
	if [[ ! -z $PIA_state ]] 
	then
		# Issue a kill on the PIA Process
		ps -ef | grep --line-buffered "Private Internet Access" | grep -m 1 --line-buffered pia_nw | awk '{print $3}' | xargs kill 2>/dev/null

		# Buffer 1 second
		sleep 1

		# Wait for openvpn to shut down
		for i in $(seq 1 $SHUTDOWN_TIMEOUT)
		do
			# PIA IP. Empty string if not running
			openvpnIP=$(ps -ef | grep --line-buffered pia_manager | grep --line-buffered openvpn | sed -l 's/.*--remote //g; s/ 8080.*//g')	
			if [[ -z $openvpnIP ]]
			then
				echo "PIA stopped."
				exit
			else 
				if [ $SHUTDOWN_TIMEOUT -eq $i ]
				then 
					echo "Uh oh. Shutdown timed out."
					exit
				fi
				sleep 1
			fi
		done
	else
		echo "PIA already stopped."
	fi
fi