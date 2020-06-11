#define SHORT_GAMEMODE_TEXT "TSRV"
#define VERSION_TEXT        "Alpha"

#define SQL_HOST  "localhost"
#define SQL_USER  "root"
#define SQL_PASSWORD  "root"
#define SQL_DATABASE  "test"

#define COLOR_WHITE     0xFFFFFF00
#define COLOR_RED       0xFF000000
#define COLOR_YELLOW    0xFFFF0000
#define COLOR_EMOTE     0xEDA4FF00

#define DIALOG_UNUSED       0
#define DIALOG_REGISTER     1
#define DIALOG_LOGIN        2

#define DEFAULT_SKIN        299
#define INVALID_WEAPON_ID   -1

#define MAX_DAMAGES         (MAX_PLAYERS * 10)


#define MAX_HOUSES          500

#define HOUSE_COMMUNE       1272
#define HOUSE_PURCHASED     19522
#define HOUSE_SALE          1273

#define BODY_PART_TORSO     3
#define BODY_PART_GROIN     4
#define BODY_PART_LEFT_ARM  5
#define BODY_PART_RIGHT_ARM 6
#define BODY_PART_LEFT_LEG  7
#define BODY_PART_RIGHT_LEG 8
#define BODY_PART_HEAD      9

#define Server:%0(%1) forward %0(%1); public %0(%1)

enum PLAYER_DATA
{
    pSQLID,
    pLevel,
    pAdminLevel,
    pCash,
    pBank,
    pRespect,
    Float:pLastPos[5],
    pLastInt,
    pLastVW
}

enum DAMAGE_DATA
{
    DamagePlayerID,
    DamageWeapon,
    DamageBodypart,
    Float:DamageAmount
}

enum HOUSE_DATA
{
    HouseID,
    HouseOwnerSQL,
    HouseName[40],
    Float:HouseExterior[4],
    Float:HouseInterior[4],
    HouseInteriorID,
    HousePrice,
    HousePickup,
    Text3D:HouseLabel
}
// Global Variables
new MySQL:sqlConnection, OneSecondTimer, lastSaveTime = 0;

// Variables
new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA], DamageData[MAX_DAMAGES][DAMAGE_DATA], totalDamages = 0;

// House Variables
new HouseData[MAX_HOUSES][HOUSE_DATA], TotalHousesCreated = 0;