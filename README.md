# PIA-Interface
An Alfred Workflow used to Start and Stop Private Internet Access services.

## Start Command Demo

![Start Demo](https://zippy.gfycat.com/DeepCalculatingIaerismetalmark.gif)

## Stop Command Demo

![Stop Demo](https://zippy.gfycat.com/ChiefOffensiveIberianemeraldlizard.gif)

## Installation
1. Download PIA Inteface.alfredworkflow
2. Open the file and Alfred will enable the workflow automatically
3. Enable "Auto-connect on launch" in the PIA Client settings

![AutoConnectSetting](http://i.imgur.com/DQFWpza.png)

## Usage
- "pia start"
  - Starts PIA application if it isn't running already. And connects VPN.
- "pia stop"
  - Shuts down VPN connection and closes PIA application.

## Keywords/Hotkeys
You can also specify keywords and hotkeys to toggle PIA start/stop. This is managed by going to the workflow settings screen inside Alfred preferences.

Default keywords are "startpia" and "stoppia" but these can be modified as you choose.

## How does it work?
The Alfred Workflow uses a bash script which starts PIA by simply executing PIA's run.sh script found in the Application packages. The state (running/stopped) is detected by monitoring the openssl process that is spawned by PIA's VPN connection. 

The script will wait until the external IP matches the IP assigned by the openssl connection. This way we can ensure the connection is secure. Internet IP is discovered using the following command: `dig +short myip.opendns.com @resolver1.opendns.com`

The PIA connection is terminated by issuing a kill to PIA's "run" process.

## Supporting future PIA versions
The Workflow currently assumes that PIA can be started and stopped through a CLI using the run.sh script found in the PIA application contents. If this is no longer the case in future releases, this workflow must be updated to make sure the script still works. If that script is removed altogether, then we'd be in trouble.

If PIA moves away from the use of openssl (very unlikely), the bash script will have to be rewritten. Or if PIA tweaks the way it uses openssl (sorta unlikely), the code will have to make sure it's still able to pick out the IP address assigned by openssl.

## Troubleshooting
The PIA Interface uses bash to issue start and stop commands. The script assumes that PIA is installed in the default location: /Applications/Private\ Internet\ Access.app.

If connectivity latency is expected, longer timeouts can be configured to accomodate slow internet speeds. Modify the following lines to increase wait time:

```
# Seconds the script will wait for PIA to get an IP assigned
OPENVPN_TIMEOUT=20

# Seconds the script will wait for the external IP to match PIA IP
EXTERNAL_IP_TIMEOUT=20

# Seconds the script will wait for openvpn to shutdown
SHUTDOWN_TIMEOUT=20
```

## Support Versions
- macOS Sierra 10.12.3
- Private Internet Access v66
