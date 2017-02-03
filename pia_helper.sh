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
openvpn_state=$(ps -ef | grep --line-buffered pia_manager | grep --line-buffered openvpn)

# PIA state
PIA_state=$(ps -ef | grep --line-buffered pia | grep --line-buffered "\-\-run")

# If not running already
if [[ -z  $openvpn_state ]]
then
	if [[ $script_command == "start" ]]
	then
		# if already running but disconnected, restart
		if [[ ! -z $PIA_state ]]
		then
			# Issue a kill on the PIA Process
			ps -ef | grep --line-buffered pia | grep --line-buffered "\-\-run" | awk '{print $2}' | xargs kill 2>/dev/null

			# Buffer 1 second
			sleep 1

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
		fi
		# Start PIA
		open -n /Applications/Private\ Internet\ Access.app &

		# Wait till openvpnIP is assigned.
		for i in $(seq 1 $OPENVPN_TIMEOUT)
		do
			# PIA IP. Empty string if not running
			openvpnIP=$(ps -ef | grep --line-buffered pia_manager | grep --line-buffered openvpn | sed -l 's/.*--remote //g; s/ 8080.*//g')	

			# Also wait till an IP is assigned
			if [[ ! -z $openvpnIP ]] && [[ $openvpnIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
			then
				break
			else 
				if [ $OPENVPN_TIMEOUT -eq $i ]
				then 
					echo "Unable to find PIA IP. Client version out of date."
					exit
				fi
				sleep 1
			fi
		done

		# Wait for external IP to pick up PIA IP
		for i in $(seq 1 $EXTERNAL_IP_TIMEOUT)
		do
			# External IP from source #1. Empty if fetch fails
			externalIP=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null)

			# Eternal IP from source #2. Runs if first attempt fails
			if [[ -z $externalIP ]]
			then
				echo "First attempt failed"
				externalIP=$(curl ipecho.net/plain 2>/dev/null)
				if [[ -z $externalIP ]]
				then
					echo "Unable to fetch external IP. Check internet connection or try again later."
					exit
				fi
			fi

			if [ "$externalIP" == "$openvpnIP" ]
			then
				echo "PIA Connection Established"
				exit
			fi

			if [ $EXTERNAL_IP_TIMEOUT -eq $i ]
			then
				echo "Took too long to establish PIA connection."
				exit
			else
				sleep 1
			fi
		done
	elif [[ $script_command == "stop" ]]
	then
		echo "PIA already stopped."
	fi
# else if already running
else
	if [[ $script_command == "start" ]]
	then
		echo "PIA already running."
	elif [[ $script_command == "stop" ]]
	then
		# Issue a kill on the PIA Process
		ps -ef | grep --line-buffered pia | grep --line-buffered "\-\-run" | awk '{print $2}' | xargs kill 2>/dev/null

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
	fi
fi