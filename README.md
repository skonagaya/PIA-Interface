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

## Troubleshooting
The PIA Interface uses bash to issue start and stop commands. The script assumes that PIA is installed in the default location: /Applications/Private\ Internet\ Access.app.

## Support Versions
- macOS Sierra 10.12.3
- Private Internet Access v66
