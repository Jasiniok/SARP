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

stock NameRP(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    strreplace(name, "_", " ");
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