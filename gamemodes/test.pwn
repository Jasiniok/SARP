#include <a_samp>
#include <zcmd>
#include <a_mysql>
#include <streamer>
#include <foreach>
#include <sscanf2>

#include "../gamemodes/Includes/VariableENums.pwn"
#include "../gamemodes/Includes/Publics.pwn"
#include "../gamemodes/Includes/OtherFunctions.pwn"


#include "../gamemodes/Includes/Commands/Account.pwn"
#include "../gamemodes/Includes/Commands/General.pwn"

main(){

}

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

public OnPlayerDisconnect(playerid, reason)
{
    DefaultPlayerValues(playerid);
    return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    return true;
}
public OnPlayerUpdate(playerid)
{

}