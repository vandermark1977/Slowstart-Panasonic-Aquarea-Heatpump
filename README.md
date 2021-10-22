# Slowstart-Panasonic-Aquarea-Heatpump
DZvents Domoticz Script to manage the Panasonic heatpump to a slow and efficient startup after restart and/or defrost.

## Definitions & abbreviations
* T-Shift:    Temperature shift in the Outlet Water Temperature from the heatpump.
* Ta:         Outlet Water Temperature
* Ta-target:  Target Outlet Water Temperature

## What does the script do?
The script is triggered by the compressor frequency. Normally after a restart or defrost there is often a significant difference between Ta and Ta-target. As a result the heatpump will start at high power to reach Ta-target in a short time. This script dynamically decreases the Ta-target in steps so that the heatpump doesn't need to provide full power and has a longer&slower (and more profitable) run to a continuous state. When Ta reaches Ta-target the T-Shift is raised +1 just as long untill Ta reaches the normal Ta-target. As a result the time between defrosts will be longer and startups are executed at lower power. 

This is especially usefull in situations where your heating system is slow and your house is well isolated. My house only has floorheating and is well isolated. The floorheating is a slow system. It is okay when the heatpump takes longer time to reach the Ta-target. Make your own judgement whether this is usefull in your situation.

Below you can see a graph of a startup after 6 hours of Off-state. The purple blocks visualize the dynamic T-shifts the script executed. It started with a T-Shift of -5 and in steps the T-Shift is decreased to final Shift of 0. The total time in which the script decreased the Ta-Target was almost one hour:
![SlowStart](https://www.bartvandermark.nl/diversen/SlowStart.JPG "Slowstart")

## Prerequisites
1. Script works in combination with the [Domoticz HeishamonMQTT plugin](https://github.com/MarFanNL/HeishamonMQTT/tree/main) and the [Heishamon communication PCB](https://www.tindie.com/stores/thehognl/)
2. The script works for two setups: The setup with a Heat Compensation Curve and the setup with direct temperature control.
3. Because of the script, the normal T-shift or Ta setting no longer works. The script has a work-around to provide a working T-Shift or Ta setting. In Domoticz you need to make a new device, device-type: Thermostat|Setpoint. In the script you need to fill in the IDX of this device in line 33.
4. To provide a minimum time of 1 minute between the T-shifts caused by the script a dummy On/Off switch is needed. Make a new On/Off switch and in the script fill in the IDX in line 32.

## Short script explanation
In the slowstart 4 'states' are defined by the script:
* 1: compressor off
* 2: compressor startup
* 3: compressor relaxing
* 4: compressor continuous operation

The steps from state 2 to state 3 and after that to to 4 are also determined by a treshold in the compressor frequency which is influenced by the Outside temperature. See lines 33-47 in the script. It is necessay that you adjust these settings, based on your own situations and regular compressor frequencies!
