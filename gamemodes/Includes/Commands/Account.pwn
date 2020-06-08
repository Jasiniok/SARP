CMD:buylevel(playerid, params[])
{
    if(!LoggedIn[playerid])return true;
    new curLevel = PlayerData[playerid][pLevel], curRespect = PlayerData[playerid][pRespect], needed = 0, string[128];
    needed = (curLevel * 8);

    if (curRespect < needed ) return
        SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have the required amount of Respect Points in order to level up.");
    PlayerData[playerid][pLevel]++;
    PlayerData[playerid][pRespect] -= needed;

    SaveSQLInt(PlayerData[playerid][pSQLID], "players", "Level", PlayerData[playerid][pLevel]);
    SaveSQLInt(PlayerData[playerid][pSQLID], "players", "Respect", PlayerData[playerid][pRespect]);
    
    format(string, sizeof(string), "Congratulations! You have leveled up to: %d. [No worries, you still have %d respect points remaining.]", PlayerData[playerid][pLevel], PlayerData[playerid][pRespect]);
    SendClientMessage(playerid, COLOR_WHITE, string);
    return true;
}