static Float:hCreateExt[4], Float:hCreateInt[4], hCreateName[40], hCreatePrice, hCreateIntID; 

LoadServerHouses()
{
    return mysql_pquery(sqlConnection, "SELECT * FROM houses ORDER BY id ASC", "SQL_LoadServerHouses");
}

Server:SQL_LoadServerHouses()
{
    if(cache_num_rows() == 0)return print ("No houses existing in the database.");

    new rows, fields;
    cache_get_row_count(rows);
    cache_get_field_count(fields);

    for (new i = 0; i < rows && i < MAX_HOUSES; i++){
        cache_get_value_name_int(i, "id", HouseData[i+1][HouseID]);
        cache_get_value_name_int(i, "OwnerID", HouseData[i+1][HouseOwnerSQL]);
        cache_get_value_name(i, "Name", HouseData[i+1][HouseName], 40);

        cache_get_value_name_float(i, "ExtX", HouseData[i+1][HouseExterior][0]);
        cache_get_value_name_float(i, "ExtY", HouseData[i+1][HouseExterior][1]);
        cache_get_value_name_float(i, "ExtZ", HouseData[i+1][HouseExterior][2]);
        cache_get_value_name_float(i, "ExtA", HouseData[i+1][HouseExterior][3]);
        cache_get_value_name_float(i, "IntX", HouseData[i+1][HouseInterior][0]);
        cache_get_value_name_float(i, "IntY", HouseData[i+1][HouseInterior][1]);
        cache_get_value_name_float(i, "IntZ", HouseData[i+1][HouseInterior][2]);
        cache_get_value_name_float(i, "IntA", HouseData[i+1][HouseInterior][3]);

        cache_get_value_name_int(i, "IntID", HouseData[i+1][HouseInteriorID]);
        cache_get_value_name_int(i, "Price", HouseData[i+1][HousePrice]);
        cache_get_value_name_int(i, "Pickup", HouseData[i+1][HousePickup]);

        TotalHousesCreated++;
    }

    CreateServerHouseData();

    printf("%i houses loaded from the database.", TotalHousesCreated);
    return true;
}

CreateServerHouseData()
{
    for(new i = 0; i < MAX_HOUSES ; i++)
    {
        if(HouseData[i][HouseID] != 0){

            HouseData[i][HousePickup] = HouseData[i][HousePickup] = CreateDynamicPickup(1273, 1, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 0, 0, -1, 10.0);
            HouseData[i][HouseLabel] = Create3DTextLabel(HouseData[i][HouseName], 0xFFFFFFFF, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 10.0, 0, 1); 
        }
    }

    return true;
}

CMD:createhouse(playerid, params[])
{
    if(PlayerData[playerid][pAdminLevel] < 5)return SendClientMessage(playerid, COLOR_RED, "You are not authorized to use this command.");

    new section[10], extra[40], string[50];
    if(sscanf(params, "s[10]S('None')[40]", section, extra))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /createhouse [exterior/interior/name/price]");
    {
        if(strmatch(section, "exterior")){
            GetPlayerPos(playerid, hCreateExt[0], hCreateExt[1], hCreateExt[2]);
            GetPlayerFacingAngle(playerid, hCreateExt[3]);
            
            SendClientMessage(playerid, COLOR_YELLOW, "Exterior Position has successfully been set.");
        }
        else if(strmatch(section, "interior")){
            hCreateIntID = GetPlayerInterior(playerid);

            GetPlayerPos(playerid, hCreateInt[0], hCreateInt[1], hCreateInt[2]);
            GetPlayerFacingAngle(playerid, hCreateInt[3]);

            SendClientMessage(playerid, COLOR_YELLOW, "Interior Position has successfully been set.");
        }
        else if(strmatch(section, "name")){
            if(strmatch(extra, "None"))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /createhouse (name) [House Name]");

            if(strlen(extra) > 39 || strlen(extra) < 3)return SendClientMessage(playerid, COLOR_WHITE, "Name length must be between 3 and 40 characters long.");

            hCreateName = extra;

            SendClientMessage(playerid, COLOR_YELLOW, "Name set successfully.");
            SendClientMessage(playerid, COLOR_WHITE, extra);
        }
        else if(strmatch(section, "price")){
            if(strmatch(extra, "None"))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /createhouse (price) [House Price]");
            if(strval(extra) < 1)return SendClientMessage(playerid, COLOR_RED, "Price has to be above $1.");

            hCreatePrice = strval(extra);

            format(string, sizeof(string), "The house's price is set to: {FFFFFF}$%i", strval(extra));
            SendClientMessage(playerid, COLOR_YELLOW, string);
        }
        else if(strmatch(section, "complete")){
            if(strmatch(extra, "None"))return SendClientMessage(playerid, COLOR_WHITE, "USAGE: /createhouse (complete) [confirm]");
            if(hCreatePrice == 0)return true;
            if(strmatch(hCreateName, "None"))return true;
            SaveHouseToDatabase(playerid);
        }
    }
    return true;
}

CMD:buyhouse(playerid, params[])
{
    new houseid = 0;

    if(CountPlayerHouses(playerid) >= 2)return SendClientMessage(playerid, COLOR_WHITE, "You already own two houses.");

    for(new i = 0; i < MAX_HOUSES; i++){
        if(HouseData[i][HouseID] != 0){
            if(IsPlayerInRangeOfPoint(playerid, 5.0, HouseData[i][HouseExterior][0], HouseData[i][HouseExterior][1], HouseData[i][HouseExterior][2])){
                houseid = i;
            }
        }
    }

    if(houseid == 0)return SendClientMessage(playerid, COLOR_WHITE, "You're not near a house that you can buy.");

    if(HouseData[houseid][HouseOwnerSQL] != 0)return SendClientMessage(playerid, COLOR_WHITE, "This house is already owned.");
    if(PlayerData[playerid][pCash] < HouseData[houseid][HousePrice])return SendClientMessage(playerid, COLOR_WHITE, "You don't have enough money to purchase this house.");
    
    new string[128];

    format(string, sizeof(string), "You have purchased '%s' for $%d, enjoy your new house!", HouseData[houseid][HouseName], HouseData[houseid][HousePrice]);
    SendClientMessage(playerid, COLOR_WHITE, string);

    GiveCash(playerid, -HouseData[houseid][HousePrice]);

    HouseData[houseid][HouseOwnerSQL] = PlayerData[playerid][pSQLID];

    SaveSQLInt(HouseData[houseid][HouseID], "houses", "OwnerSQL", HouseData[houseid][HouseOwnerSQL]);
    return true;
}

Server:SaveHouseToDatabase(playerid)
{
    new interiorid = hCreateIntID, price = hCreatePrice, name[40], Float:ext[4], Float:int[4], query[312];
    format(name, sizeof(name), hCreateName);

    ext[0]=hCreateExt[0];
    ext[1]=hCreateExt[1];
    ext[2]=hCreateExt[2];
    ext[3]=hCreateExt[3];
    int[0]=hCreateInt[0];
    int[1]=hCreateInt[1];
    int[2]=hCreateInt[2];
    int[3]=hCreateInt[3];

    mysql_format(sqlConnection, query, sizeof(query), "INSERT INTO houses (`OwnerSQL`, `Name`, `ExtX`, `ExtY`, `ExtZ`, `ExtA`, `IntX`, `IntY`, `IntZ`, `IntA`, `IntID`, `Price`) VALUES(0, '%e', %f, %f, %f, %f, %f, %f, %f, %f, %i, %i)", name, ext[0], ext[1], ext[2], ext[3], int[0], int[1], int[2], int[3], interiorid, price);
    mysql_pquery(sqlConnection, query, "SQL_SaveHouseToDB", "");
    
    return true;
}

Server:SQL_SaveHouseToDB(playerid)
{
    TotalHousesCreated++;
    new interiorid = hCreateIntID, price = hCreatePrice, name[40], Float:ext[4], Float:int[4], i = TotalHousesCreated, string[128];
    format(name, sizeof(name), hCreateName);

    ext[0]=hCreateExt[0];
    ext[1]=hCreateExt[1];
    ext[2]=hCreateExt[2];
    ext[3]=hCreateExt[3];
    int[0]=hCreateInt[0];
    int[1]=hCreateInt[1];
    int[2]=hCreateInt[2];
    int[3]=hCreateInt[3];

    HouseData[i][HouseID] = cache_insert_id();
    HouseData[i][HouseOwnerSQL] = 0;

    format(HouseData[i][HouseName], 40, name);

    HouseData[i][HouseExterior][0] = ext[0];
    HouseData[i][HouseExterior][1] = ext[1];
    HouseData[i][HouseExterior][2] = ext[2];
    HouseData[i][HouseExterior][3] = ext[3];
    HouseData[i][HouseInterior][0] = int[0];
    HouseData[i][HouseInterior][1] = int[1];
    HouseData[i][HouseInterior][2] = int[2];
    HouseData[i][HouseInterior][3] = int[3];

    HouseData[i][HouseInteriorID] = interiorid;
    HouseData[i][HousePrice] = price;

    printf("House ID %i created by: %s", cache_insert_id(), GetName(playerid));

    format(string, sizeof(string), "House ID %i (SQLID:%i) created: %s, $%d", i, cache_insert_id(), name, price);
    SendClientMessage(playerid, COLOR_YELLOW, string);

    HouseData[i][HousePickup] = CreateDynamicPickup(1273, 1, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 0, 0, playerid = -1, 10.0);
    HouseData[i][HouseLabel] = Create3DTextLabel(HouseData[i][HouseName], 0xFFFFFFFF, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 10.0, 0, 1); 

    hCreateIntID = 0;
    hCreatePrice = 999999999;
    hCreateName = "None";
    for(new j = 0; j < 4; j++){ hCreateInt[j] = 0.0; hCreateExt[j] = 0.0; }

    return true;
}

