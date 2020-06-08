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

    format(string, sizeof(string), "%s attempts to %s and ", NameRP(playerid), params);
    switch(rand){
        case 0 .. 25:strins(string, "fails...", strlen(string));
        default:strins(string, "succeeds...", strlen(string));
    }
    SendLocalMessage(playerid, COLOR_EMOTE, string);
    return true;
}