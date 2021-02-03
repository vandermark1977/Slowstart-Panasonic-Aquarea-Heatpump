# Slowstart-Panasonic-Aqarea-Heatpump
DZvents Domoticz Script to manage the Panasonic (monobloc) heatpump to a slow and efficient startup after restart and/or defrost.
Script works in combination with the Domoticz plugin (https://github.com/MarFanNL/HeishamonMQTT/tree/main) and the heishamon control board (https://www.tindie.com/stores/thehognl/)

The script is triggered by compressor frequency change and sets a Shift in Ta so the heatpump doesnot go @ high power after a restart or defrost.

The script only functions when you have set up the Pana heatpump with a compensation curve for the Target Water Temperature Control. Manually Shifting with the Panasonic control unit doesnot work when the script is active. You need to use a Domoticz Shift (temperature thermostat) to be able to make manual shifts to the T-target water outlet temperature. See script for details.

In domoticz you need an on/off switch created from a Dummy device. This switch is needed to add a minimum time of 1 minute between Ta Shifts.
