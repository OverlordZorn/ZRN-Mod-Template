#define MAJOR 1
#define MINOR 0
#define PATCH 0
#define BUILD 0
#define COMMIT empty

// #define VERSION MACROS
#define VERSION MAJOR.MINOR
#define VERSION_AR MAJOR,MINOR,PATCH,BUILD
#define VERSION_STR MAJOR##.##MINOR##.##PATCH##.##BUILD