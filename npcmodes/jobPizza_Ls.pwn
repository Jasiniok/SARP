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
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT,"jobPizza_Ls");
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
