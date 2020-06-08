#include <a_samp>
#include <zcmd>
#include <a_mysql>
#include <streamer>
#include <foreach>

enum PLAYER_DATA
{
    pSQLID,
    pLevel,
    pAdminLevel
    pCash
    pBank
}

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
    mysql_log(ALL);
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
    return true;
    DefaultPlayerValues(playerid);
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

    }
    else // Doesn't exist
    {
        ShowRegisterDialog(playerid, "");
    }
    return exists;

}

Server:ShowRegisterDialog(playerid, error[])
{
    if(LoggedIn[playerid]) return true;

    if(!strmatch(error, "")){
        SendClientMessage(playerid, COLOR_WHITE, error);
    }
    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Tutorial Server - Register", "Please enter a password so you can register.", "Register", "Quit")

}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_REGISTER:
        {
            if(!response)return Kick(playerid);

            if(strlen(inputtext) < 3 || strlen(inputtext) > 30)
            ShowRegisterDialog(playerid, "Password Length must be above 3 characters and below 30 characters.");
            return true;

            new query[128];
            mysql_format(sqlConnection, query, sizeof(query), "INSERT into players (Name, Password, RegIP) VALUES('%e', sha1('%e'), '%e')", GetName(playerid), inputtext, GetIP(playerid));
            mysql_pquery(sqlConnection, query, "SQL_OnAccountRegister", "i", playerid);
        }
    }
    return false;
}

Server:SQL_OnAccountRegister(playerid)
{
    SendClientMessage(playerid, COLOR_WHITE, "You have been successfully registered to the server.")

    DefaultPlayerValues(playerid);

    PlayerData[playerid][pSQLID] = cache_insert_id();
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
    PlayerData[playerid][pLevel = 0;
    PlayerData[playerid][pAdminLevel] = 0;
    PlayerData[playerid][pCash] = 0;
    PlayerData[playerid][pBank] = 0;
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
    GetPlayerName(playerid, const name[], len);
}

stock strmatch(const String1[], const String2[])
{
    if((strcmp(String1, String2[], true, strlen(String2)) = 0) && (strlen(String2) == strlen(String1)))
    {
        return true;
    }
    else
    {
        return false;
    }
}
