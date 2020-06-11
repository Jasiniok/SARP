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
    new string[40];

    for(new i = 0; i < MAX_HOUSES ; i++)
    {
        if(HouseData[i][HouseID] != 0){
            HouseData[i][HousePickup] = CreatePickup(HOUSE_SALE, 1, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 0);
            
            HouseData[i][HouseLabel] = Create3DTextLabel(HouseData[i][HouseName], 0xFFFFFFFF, HouseData[i+1][HouseExterior][0], HouseData[i+1][HouseExterior][1], HouseData[i+1][HouseExterior][2], 10.0, 0, 1); 
        }
    }

    return true;
}