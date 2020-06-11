CMD:skin(playerid,params[])
{
    new skinnumber, skinid, string[128];
    if(sscanf(params, "d", skinid)) SendClientMessage(playerid, -1, "{ffff00}=USAGE=: {ffffff}/skin <skinid>");
    else
    {
        SetPlayerSkin(playerid, skinid);
        skinnumber = GetPlayerSkin(playerid);
        format(string, sizeof(string), "{ffff00}=INFO=: {ffffff}You have changed your skin to %d", skinnumber);
        SendClientMessage(playerid, -1, string);
    }
    return 1;
}