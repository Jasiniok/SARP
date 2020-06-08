#include <a_samp>
#include <zcmd>
#include <a_mysql>
#include <streamer>
#include <foreach>

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

#define COLOR_WHITE 0xFFFFFF00

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

// Public functions
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