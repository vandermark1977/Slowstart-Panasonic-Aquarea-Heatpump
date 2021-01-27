# Slowstart-Panasonic-Aqarea-Heatpump
Script to manage the Panasonic heatpump to a slow and efficient startup after (for example) defrost. 
Script is based on Domoticz in combination with the Domoticz plugin (https://github.com/MarFanNL/HeishamonMQTT/tree/main)
The script is triggered by compressor frequency change and sets a Shift in Ta so the heatpump doesnot go @ high power after a restart or defrost.

You need an on/off switch created from a Dummy device. This switch is needed to add a minimum time of 1 minute between Ta Shifts.
