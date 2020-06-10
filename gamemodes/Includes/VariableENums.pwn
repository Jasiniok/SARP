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

#define HOST_NAME "Test Server"

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

#define Server:%0(%1) forward %0(%1); public %0(%1)
// Global Variables
new MySQL:sqlConnection, OneSecondTimer, lastSaveTime = 0;

// Variables
new bool:LoggedIn[MAX_PLAYERS], PlayerData[MAX_PLAYERS][PLAYER_DATA];