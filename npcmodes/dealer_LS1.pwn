//
// Mode Npc
// By Dark_Rider
//

#include <a_npc>

//------------------------------------------
main(){}
//------------------------------------------

NextPlayback()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT,"dealer_LS1");
}
//------------------------------------------
public OnRecordingPlaybackEnd()
{
    NextPlayback();
}
//------------------------------------------

public OnNPCSpawn()
{
    NextPlayback();
}
//------------------------------------------
