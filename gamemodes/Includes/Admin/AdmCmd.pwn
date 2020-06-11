CMD:skin(playerid,params[])
{
    new skinnumber, skinid, string[128];
    if(sscanf(params, "d", skinid))return SendClientMessage(playerid, -1, "{ffff00}=USAGE=: {ffffff}/skin <skinid>");
    else
    {
        SetPlayerSkin(playerid, skinid);
        skinnumber = GetPlayerSkin(playerid);
        format(string, sizeof(string), "{ffff00}=INFO=: {ffffff}You have changed your skin to %d", skinnumber);
        SendClientMessage(playerid, -1, string);
    }
    return 1;
}

CMD:setvw(playerid, params[])
{
    new id, virtualworld, stringid[128], stringplayerid[128];
    if(sscanf(params, "ui", id, virtualworld))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /setvw <ID> <VW Number>");
    else{
        SetPlayerVirtualWorld(id, virtualworld);

        format(stringid, sizeof(stringid), "You have been brought to Virtual World %i by %s", virtualworld, NameRP(playerid));
        SendClientMessage(id, COLOR_YELLOW, stringid);
        format(stringplayerid, sizeof(stringplayerid), "You have sent %s to Virtual World %i", virtualworld, NameRP(id));
        SendClientMessage(playerid, COLOR_YELLOW, stringplayerid);
    }

    return true;
}