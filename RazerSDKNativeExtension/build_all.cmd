SET NO_PAUSE=true
cd AirRazerSDKPlugin
CALL build_aar.cmd
cd ..
CALL build_ane.cmd
CALL copy_ane.cmd
