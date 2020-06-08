Server:SQL_OnAccountLogin(playerid)
{
    if(cache_num_rows() == 0){
        ShowLoginDialog(playerid, "Incorrect password.");
        return true;
    }

    SendClientMessage(playerid, COLOR_WHITE, "You have successfully logged in to the server.");
    PlayerData[playerid][pSQLID] = cache_get_field_content_int(0, "id", sqlConnection);
    PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);

    LoadPlayerData(playerid);
    return true;    
}

Server:SQL_OnLoadAccount(playerid)
{
    LoggedIn[playerid] = true;

    PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);
    PlayerData[playerid][pCash] = cache_get_field_content_int(0, "Cash", sqlConnection);
    PlayerData[playerid][pLevel] = cache_get_field_content_int(0, "Level", sqlConnection);
    PlayerData[playerid][pRespect] = cache_get_field_content_int(0, "Respect", sqlConnection);

    PlayerData[playerid][pLastPos][0] = cache_get_field_content_float(0, "LastX", sqlConnection);
    PlayerData[playerid][pLastPos][1] = cache_get_field_content_float(0, "LastY", sqlConnection);
    PlayerData[playerid][pLastPos][2] = cache_get_field_content_float(0, "LastZ", sqlConnection);
    PlayerData[playerid][pLastPos][3] = cache_get_field_content_float(0, "LastRot", sqlConnection);

    PlayerData[playerid][pLastInt] = cache_get_field_content_int(0, "Interior", sqlConnection);
    PlayerData[playerid][pLastVW] = cache_get_field_content_int(0, "VW", sqlConnection);

    SetPlayerScore(playerid, PlayerData[playerid][pLevel]);

    ResetPlayerMoney(playerid); GivePlayerMoney(playerid, PlayerData[playerid][pCash]);

    SetPlayerSpawn(playerid);
    return true;
}

Server:TIMER_OneSecondTimer()
{
    foreach (Player, i){
        if(LoggedIn[i]){
            lastSaveTime++;
            if(lastSaveTime < 5) {
                SavePlayerPosition(i, false);
            }
            else{
                SavePlayerPosition(i, true);
                lastSaveTime = 0;
            }
        }
    }
    return true;
}

Server:SavePlayerPosition(playerid, bool:save)
{
    GetPlayerPos(playerid, PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2]);
    GetPlayerFacingAngle(playerid, PlayerData[playerid][pLastPos][3]);

    PlayerData[playerid][pLastInt] = GetPlayerInterior(playerid);
    PlayerData[playerid][pLastVW] = GetPlayerVirtualWorld(playerid);

    if (save) {
        new query[123];
        mysql_format(sqlConnection, query, sizeof(query), "UPDATE players SET LastX = %f, LastY = %f, LastZ = %f, LastRot = %f, Interior = %i, VW = %i WHERE id = %i LIMIT 1",
        PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2], PlayerData[playerid][pLastPos][3], 
        PlayerData[playerid][pLastInt], PlayerData[playerid][pLastVW], PlayerData[playerid][pSQLID]);
        mysql_pquery(sqlConnection, query);
    }
    return true;
}

Server:SetPlayerSpawn(playerid)
{
    SetSpawnInfo(playerid, 0, DEFAULT_SKIN, PlayerData[playerid][pLastPos][0], PlayerData[playerid][pLastPos][1], PlayerData[playerid][pLastPos][2], PlayerData[playerid][pLastPos][3], 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);

    SetPlayerVirtualWorld(playerid, PlayerData[playerid][pLastVW]);
    SetPlayerInterior(playerid, PlayerData[playerid][pLastInt]);
    return true;
}

Server:LoadPlayerData(playerid)
{
    new query[128];
    mysql_format(sqlConnection, query, sizeof(query), "SELECT * FROM players WHERE id = %i LIMIT 1", PlayerData[playerid][pSQLID]);
    mysql_pquery(sqlConnection, query, "SQL_OnLoadAccount", "i", playerid);
    return true;
}

Server:SQL_OnAccountRegister(playerid)
{
    SendClientMessage(playerid, COLOR_WHITE, "You have been successfully registered to the server.");
    DefaultPlayerValues(playerid);

    PlayerData[playerid][pSQLID] = cache_insert_id();
    LoadPlayerData(playerid);   
    return true;
}

Server:SaveSQLInt(sqlid, table[], row[], value)
{
    new query[256];
    mysql_format(sqlConnection, query, sizeof(query), "UPDATE %e SET %e = %i WHERE id = %i", table, row, value, sqlid);
    mysql_pquery(sqlConnection, query);
    return true;
}
Server:DefaultPlayerValues(playerid)
{
    PlayerData[playerid][pSQLID] = 0;
    PlayerData[playerid][pLevel] = 1;
    PlayerData[playerid][pAdminLevel] = 0;
    PlayerData[playerid][pCash] = 0;
    PlayerData[playerid][pBank] = 0;
    PlayerData[playerid][pRespect] = 0;
    return true;
}

Server:DoesPlayerExist(playerid)
{
    new query[128];
    mysql_format(sqlConnection, query, sizeof(query), "SELECT id from players WHERE name = '%e' LIMIT 1", GetName(playerid));
    mysql_pquery(sqlConnection, query, "SQL_DoesPlayerExist", "i", playerid);
    return true;
}

Server:SQL_DoesPlayerExist(playerid)
{
    if(cache_num_rows(sqlConnection) != 0) // Exists
    {
        ShowLoginDialog(playerid, "");
    }
    else // Doesn't exist
    {
        ShowRegisterDialog(playerid, "");
    }
    return true;

}

Server:ShowLoginDialog(playerid, error[])
{
    if(LoggedIn[playerid])return true;

    if(!strmatch(error, "")){
        SendClientMessage(playerid, COLOR_WHITE, error);
    }
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Tutorial Server - Login", "This account is registered. \nPlease enter your password so you can proceed.", "Login", "Quit");
    return true;
}

Server:ShowRegisterDialog(playerid, error[])
{
    if(LoggedIn[playerid]) return true;

    if(!strmatch(error, "")){
        SendClientMessage(playerid, COLOR_WHITE, error);
    }
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Tutorial Server - Register", "Please enter a password so you can register.", "Register", "Quit");

    return true;
}

Server:GetDistanceBetweenPlayers(playerid, id, Float:distance)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(LoggedIn[id] && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(id) && GetPlayerInterior(playerid) == GetPlayerInterior(id)){
        if(IsPlayerInRangeOfPoint(id, distance, x, y, z)){
                return true;
        }
    }
    return false;
}

Server:SendLocalMessage(playerid, color,  msg[])
{
    if(!LoggedIn[playerid])return true;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    foreach(Player, i){
        if(LoggedIn[i]){
            if(IsPlayerInRangeOfPoint(i, 15.0, x, y, z) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)){
                SendClientMessage(i, color, msg);
            }
        }
    }
    return true;
}

Server:SendLocalMessageEx(playerid, color,  msg[], Float:distance)
{
    if(!LoggedIn[playerid])return true;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    foreach(Player, i){
        if(LoggedIn[i]){
            if(IsPlayerInRangeOfPoint(i, distance, x, y, z) && GetPlayerInterior(i) == GetPlayerInterior(playerid) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid)){
                SendClientMessage(i, color, msg);
            }
        }
    }
    return true;
}