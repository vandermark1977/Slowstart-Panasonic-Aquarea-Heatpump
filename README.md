# Slowstart-Panasonic-Aqarea-Heatpump
DZvents Domoticz Script to manage the Panasonic (monobloc) heatpump to a slow and efficient startup after restart and/or defrost.

## Definitions & abbreviations
* T-Shift: Temperature shift in the Outlet Water Temperature from the heatpump.
* Ta: Outlet Water Temperature
* Ta-target: Target Outlet Water Temperature

## Prerequisites
1. Script works in combination with the [Domoticz plugin](https://github.com/MarFanNL/HeishamonMQTT/tree/main) and the [heishamon control board](https://www.tindie.com/stores/thehognl/)
2. Because of the script, the normal T-shift no longer works. The script has a work-around to provide a working T-Shift. In Domoticz you need to make a new device: Thermostat|Setpoint. In the script you need to fill in the IDX of this device in line 32
3. To provide a minimum time of 1 minute between the T-shifts caused by the script a dummy On/Off switch is needed. Make a new On/Off switch and in the script fill in the IDX in line 31.

## What does the script do?
The script is triggered by the compressor frequency. Normally after a restart or defrost there is a significant difference between Ta and Ta-target. As a result the heatpump will start at high power to reach Ta-target in a short time. This script dynamically lowers the Ta-target so that the heatpump doesn't need to provide full power and has a longer&slower (and more profitable) run to a continuous state. When Ta reaches Ta-target the T-Shift is raised +1 just as long untill Ta reaches the normal Ta-target. In the process 4 'states' are defined by the script:
* 1: compressor off
* 2: compressor startup
* 3: compressor relaxing
* 4: compressor continuous operation

The steps from state 2 to state 3 and after that to to 4 are also determined by a treshold in the compressor frequency which is influenced by the Ta-target. See lines 33-47 in the script. It is necessay that you adjust these settings, based on your own situations and regular compressor frequencies!

The script only functions when you have set up the Pana heatpump with a heat compensation curve for the Target Water Temperature Control. Manually Shifting with the Panasonic control unit doesnot work when the script is active. You need to use a new Shift device (devicetype: thermostat|setpoint) to be able to make manual shifts to the T-target water outlet temperature. See script for details.

In domoticz you need an on/off switch created from a Dummy device. This switch is needed to add a minimum time of 1 minute between Ta Shifts.
