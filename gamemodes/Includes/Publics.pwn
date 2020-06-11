Server:SQL_OnAccountLogin(playerid)
{
    if(cache_num_rows() == 0){
        ShowLoginDialog(playerid, "Incorrect password.");
        return true;
    }

    SendClientMessage(playerid, COLOR_WHITE, "You have successfully logged in to the server.");
    cache_get_value_name_int(0, "id", PlayerData[playerid][pSQLID]);
    cache_get_value_name_int(0, "AdminLevel", PlayerData[playerid][pAdminLevel]);

    LoadPlayerData(playerid);
    return true;    
}

Server:SQL_OnLoadAccount(playerid)
{
    LoggedIn[playerid] = true;

    cache_get_value_name_int(0, "AdminLevel", PlayerData[playerid][pAdminLevel]);
    cache_get_value_name_int(0, "Cash", PlayerData[playerid][pCash]);
    cache_get_value_name_int(0, "Level", PlayerData[playerid][pLevel]);
    cache_get_value_name_int(0, "Respect", PlayerData[playerid][pRespect]);


    cache_get_value_name_float(0, "LastX", PlayerData[playerid][pLastPos][0]);
    cache_get_value_name_float(0, "LastY", PlayerData[playerid][pLastPos][1]);
    cache_get_value_name_float(0, "LastZ", PlayerData[playerid][pLastPos][2]);
    cache_get_value_name_float(0, "LastRot", PlayerData[playerid][pLastPos][3]);

    cache_get_value_name_int(0, "Interior", PlayerData[playerid][pLastInt]);
    cache_get_value_name_int(0, "VW", PlayerData[playerid][pLastVW]);

    SetPlayerScore(playerid, PlayerData[playerid][pLevel]);

    ResetPlayerMoney(playerid); GivePlayerMoney(playerid, PlayerData[playerid][pCash]);

    TogglePlayerSpectating(playerid, false);
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

    ResetDamageData(playerid);
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
    if(cache_num_rows() != 0) // Exists
    {
        ShowLoginDialog(playerid, "");
    }
    else // Doesn't exist
    {
        ShowRegisterDialog(playerid, "");
    }

    SetPlayerPos(playerid, 1481.1636, -1758.3107, 17.5313);
    SetPlayerCameraLookAt(playerid, 1481.1636, -1758.3107, 17.5313);
    SetPlayerCameraPos(playerid, 1475.2010, -1700.4648, 53.6622);

    TogglePlayerSpectating(playerid, true);
    return true;
}

Server:TIMER_SetCameraPos(playerid)
{
    SetPlayerPos(playerid, 1481.1636, -1758.3107, 17.5313);
    SetPlayerCameraLookAt(playerid, 1481.1636, -1758.3107, 17.5313);
    SetPlayerCameraPos(playerid, 1475.2010, -1700.4648, 53.6622);
    return true;
}

Server:ShowLoginDialog(playerid, const error[])
{
    if(LoggedIn[playerid])return true;

    if(!strmatch(error, "")){
        SendClientMessage(playerid, COLOR_WHITE, error);
    }
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Tutorial Server - Login", "This account is registered. \nPlease enter your password so you can proceed.", "Login", "Quit");
    return true;
}

Server:ShowRegisterDialog(playerid, const error[])
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

GetDamageType(weaponid)
{
    new damageType[25] = EOS;

    switch(weaponid)
    {
        case 0 .. 3, 5 .. 7, 10 .. 15:damageType = "Blunt Trauma";
        case 4, 8, 9:damageType = "Stab Wound";
        case 22 .. 34:damageType = "Gunshot Wound";
        case 16, 18, 35, 36, 37, 39, 40:damageType = "Explosive/Burn Wound";
        default:damageType = "Unknown";
    }
    return damageType;
}

Server:ResetDamageData(playerid)
{
    for(new i = 0; i < MAX_DAMAGES; i++){
        if(DamageData[i][DamagePlayerID] == playerid){
            DamageData[i][DamagePlayerID] = INVALID_PLAYER_ID;
            DamageData[i][DamageWeapon] = INVALID_WEAPON_ID;
            DamageData[i][DamageBodypart] = 0;
            DamageData[i][DamageAmount] = 0.0;
        }
    }
    return true;
}

Server:SaveDamageData(playerid, weaponid, bodypart, Float:amount)
{
    totalDamages ++;
    new i = totalDamages;

    DamageData[i][DamagePlayerID] = playerid;
    DamageData[i][DamageWeapon] = weaponid;
    DamageData[i][DamageBodypart] = bodypart;
    DamageData[i][DamageAmount] = amount;
    return true;
}

GetBoneDamaged(bodypart)
{
    new bodypartR[20] = EOS;
    switch(bodypart)
    {
        case BODY_PART_TORSO:bodypartR = "Chest";
        case BODY_PART_GROIN:bodypartR = "Groin";
        case BODY_PART_LEFT_ARM:bodypartR = "Left Arm";
        case BODY_PART_RIGHT_ARM:bodypartR = "Right Arm";
        case BODY_PART_LEFT_LEG:bodypartR = "Left Leg";
        case BODY_PART_RIGHT_LEG:bodypartR = "Right Leg";
        case BODY_PART_HEAD:bodypartR = "Head"; 
    }
    return bodypartR;
}

Server:DisplayDamageData(playerid, forplayerid)
{
    new count = 0;
    for(new i = 0; i < MAX_DAMAGES; i++){
        if(DamageData[i][DamagePlayerID] == playerid){
            count++;
        }
    }
    
    if(!count)return SendClientMessage(forplayerid, COLOR_WHITE, "That player hasn't been injured/wounded.");

    new longstr[512] = EOS, weaponname[20] = EOS;
    for(new i = 0; i < MAX_DAMAGES; i++){
        if(DamageData[i][DamagePlayerID] == playerid){
            GetWeaponName(DamageData[i][DamageWeapon], weaponname, sizeof(weaponname));
            format(longstr, sizeof(longstr), "%s{FFFFFF} (%s - %s) %s\n", longstr, GetDamageType(DamageData[i][DamageWeapon]), GetBoneDamaged(DamageData[i][DamageBodypart]), weaponname);
        }
    }

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_LIST, "Damage Information", longstr, "Close", "");
    return true;
}