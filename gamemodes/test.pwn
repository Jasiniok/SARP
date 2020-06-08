#include <a_samp>
#include <zcmd>
#include <a_mysql>
#include <streamer>
#include <foreach>
#include <sscanf2>

enum PLAYER_DATA
{
    pSQLID,
    pLevel,
    pAdminLevel,
    pCash,
    pBank,
    pRespect
}

#define HOST_NAME "Test Server"

#define SQL_HOST  "localhost"
#define SQL_USER  "root"
#define SQL_DATABASE  "test"
#define SQL_PASSWORD  "root"

#define COLOR_WHITE     0xFFFFFF00
#define COLOR_RED       0xFF000000
#define COLOR_YELLOW    0xFFFF0000
#define COLOR_EMOTE     0xEDA4FF00

#define DIALOG_UNUSED       0
#define DIALOG_REGISTER     1
#define DIALOG_LOGIN        2


#define Server:%0(%1) forward %0(%1); public %0(%1)
// Global Variables
new sqlConnection;

main(){

}

// Variables
new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA];

public OnGameModeInit()
{
    mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);
    sqlConnection = mysql_connect(SQL_HOST, SQL_USER, SQL_DATABASE, SQL_PASSWORD);
    return true;
}

public OnGameModeExit()
{
    mysql_close(sqlConnection);
    return true;
}

public OnPlayerConnect(playerid)
{
    DoesPlayerExist(playerid);
    DefaultPlayerValues(playerid);
    return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_REGISTER:
        {
            if(!response)return Kick(playerid);

            if(strlen(inputtext) < 3 || strlen(inputtext) > 30){
            ShowRegisterDialog(playerid, "Password Length must be above 3 characters and below 30 characters.");
            return true;
            }
            
            new query[128];
            mysql_format(sqlConnection, query, sizeof(query), "INSERT into players (Name, Password, RegIP) VALUES('%e', sha1('%e'), '%e')", GetName(playerid), inputtext, GetIP(playerid));
            mysql_pquery(sqlConnection, query, "SQL_OnAccountRegister", "i", playerid);
        }
        case DIALOG_LOGIN:
        {
            if(!response)return Kick(playerid);

            if(strlen(inputtext) < 3 || strlen(inputtext) > 30){
            ShowLoginDialog(playerid, "Password Length must be above 3 characters and below 30 characters.");
            return true;
            }

            new query[128];
            mysql_format(sqlConnection, query, sizeof(query), "SELECT id from players WHERE Name = '%e' AND Password = sha1('%e') LIMIT 1", GetName(playerid), inputtext);
            mysql_pquery(sqlConnection, query, "SQL_OnAccountLogin", "i", playerid);
        }
    }
    return false;
}

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
    PlayerData[playerid][pAdminLevel] = cache_get_field_content_int(0, "AdminLevel", sqlConnection);
    PlayerData[playerid][pCash] = cache_get_field_content_int(0, "Cash", sqlConnection);
    PlayerData[playerid][pLevel] = cache_get_field_content_int(0, "Level", sqlConnection);
    PlayerData[playerid][pRespect] = cache_get_field_content_int(0, "Respect", sqlConnection);

    SetPlayerScore(playerid, PlayerData[playerid][pLevel]);

    ResetPlayerMoney(playerid); GivePlayerMoney(playerid, PlayerData[playerid][pCash]);
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

public OnPlayerDisconnect(playerid, reason)
{
    DefaultPlayerValues(playerid);
    return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    return true;
}
public OnPlayerUpdate()
{

}

// Server Commands
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


// Account Commands


// General Commands
CMD:b(playerid, params[])
{
    if(!LoggedIn[playerid])return true;
    
    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /b [Local OOC chat message]");

    new string[128];
    format(string, sizeof(string), "(( [OOC - Local] %s says: %s", NameRP(playerid), params);
    SendLocalMessage(playerid, COLOR_YELLOW, string);
    return true;
}

CMD:pm(playerid, params[])
{
    if(!LoggedIn[playerid])return true;
    new id, msg[80], string[128];
    
    if(sscanf(params, "us[80]", id, msg))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /pm [Player ID or Name] [Message]");
    {
        if(playerid == id)return SendClientMessage(playerid, COLOR_WHITE, "You can't send a PM to yourself, boomer.");
        if(!IsPlayerConnected(id))return SendClientMessage(playerid, COLOR_WHITE, "That player is not connected.");
        if(!LoggedIn[id])return SendClientMessage(playerid, COLOR_WHITE, "That player is not logged in yet.");

        format(string, sizeof(string), "(( [PM From %s]: %s", NameRP(playerid), msg);
        SendClientMessage(id, COLOR_YELLOW, string);
        format(string, sizeof(string), "(( [PM To %s]: %s", NameRP(id), msg);
        SendClientMessage(playerid, COLOR_YELLOW, string);
    }
    return true;
}

CMD:shout(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /(s)hout [Shout Message]");
    
    new string[128];
    format(string, sizeof(string), "%s shouts: %s", NameRP(playerid), params);
    SendLocalMessageEx(playerid, COLOR_WHITE, string, 20.0);
    return true;
}
CMD:s(playerid, params[])return cmd_shout(playerid, params);

CMD:low(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /(l)ow [Low Message]");

    new string[128];
    format(string, sizeof(string), "%s says (low): %s", NameRP(playerid), params);
    SendLocalMessageEx(playerid, COLOR_WHITE, string, 7.5);
    return true;
}
CMD:l(playerid, params[])return cmd_low(playerid, params);

CMD:whisper(playerid, params[]){
    if(!LoggedIn[playerid])return true;
    new id, msg[80], string[128], bubble[128];

    if(sscanf(params, "us[80]", id, msg))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /(w)hisper [Player ID or Name] [Whisper Message]");
    {
        if(!IsPlayerConnected(id))return SendClientMessage(playerid, COLOR_WHITE, "That player is not connected.");
        if(!LoggedIn[id])return SendClientMessage(playerid, COLOR_WHITE, "That player is not logged in.");
        
        if(GetDistanceBetweenPlayers(playerid, id, 3.5))return SendClientMessage(playerid, COLOR_WHITE, "You must be close to that player to be able to whisper to them.");

        format(string, sizeof(string), "[Whisper from %s]: %s", NameRP(playerid), msg);
        SendClientMessage(id, COLOR_YELLOW, string);
        format(string, sizeof(string), "[Whisper to %s]: %s", NameRP(id), msg);
        SendClientMessage(playerid, COLOR_YELLOW, string);

        format(bubble, sizeof(bubble), "%s whispers something to %s", NameRP(playerid), NameRP(id));
        SetPlayerChatBubble(playerid, bubble, COLOR_EMOTE, 7.5, 5000);
    }
    
    return true;
}
CMD:w(playerid, params[])return cmd_whisper(playerid, params);

CMD:me(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /me [Action Message]");

    new string[128];
    format(string, sizeof(string), "* %s %s", NameRP(playerid), params);
    SendLocalMessage(playerid, COLOR_EMOTE, string);
    return true;
}

CMD:do(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /do [Describing Message]");

    new string[128];
    format(string, sizeof(string), "* %s (( %s ))", params, NameRP(playerid));
    SendLocalMessage(playerid, COLOR_EMOTE, string);
    return true;
}

CMD:ame(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /ame [Annonation Message]");

    SetPlayerChatBubble(playerid, params, COLOR_EMOTE, 15.0, 7500);
    
    new string[128];
    format(string, sizeof(string), "* Annotated Message: %s", params);
    SendClientMessage(playerid, COLOR_EMOTE, string);
    return true;
}

CMD:try(playerid, params[])
{
    if(!LoggedIn[playerid])return true;

    if(isnull(params))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /try [Attempt Message]");

    new string[128], rand = (0 + random(50));

    format(string, sizeof(string), "%s attempts to %s and ", NameRP(playerid), params)
    switch(rand){
        case 0 .. 25:strins(string, "fails...", strlen(string));
        default:strins(string, "succeeds...", strlen(string));
    }
    SendLocalMessage(playerid, COLOR_EMOTE, string);
    return true;
}



// Public functions
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

// Stocks and other functions
GetIP(playerid)
{
    new ip[20];
    GetPlayerIp(playerid, ip, sizeof(ip));
    return ip;
}

GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

NameRP(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    for (new i = 0; i < strlen(name); i++){
        if(name[i] == '_'){
            name[i] = ' ';
        }
    }
    return true;
}

stock strmatch(const String1[], const String2[])
{
    if ((strcmp(String1, String2, true, strlen(String2)) == 0) && (strlen(String2) == strlen(String1)))
    {
        return true;
    }
    else
    {
        return false;
    }
}