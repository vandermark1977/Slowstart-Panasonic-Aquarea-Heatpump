Script ot manage slow an efficient startup after (for example) defrost.
Script is based on Domoticz in combination with the Domoticz plugin (https://github.com/MarFanNL/HeishamonMQTT/tree/main)
Go to: <Settings> <More Options> <Events>
Click <+> and add new script >> DZVents >> All
  "Select all / CTRL+A" and copy this script over the standard script
  Give the script a clear name (next to ON/OFF toggle)
  Hit "OFF" on the top left corner and "SAVE" top right corner
  Line 18: CompressorFreq sensor IDX number to be filled in. (Standard: Compressor_Freq)
  Line 32: heatshift sensor IDX number to be filled in. (standard: Z1_Heat_Request_Temp)
  Line 33: target_temp sensor IDX number to be filled in. (Standard: Main_Target_Temp)
  Line 34: outlet_temp sensor IDX number to be filled in.  (Standard: Main_Outlet_Temp)
  Line 35: CompressorFreq sensor IDX number to be filled in. (Standard: Compressor_Freq)
  IDX numbers can easilly be found by tapping the "hamburger menu button" next to the "tabs" of the scripts (top left corner) and searching (Ctrl + F) for the text behind "standard:" between the brackets.
  HIT "ON" on the top left corner and hit "SAVE" on the top right corner and wait for a restart/defrost
