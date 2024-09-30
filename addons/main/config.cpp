#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        author = "$STR_mod_author";
        name = QUOTE(ADDON);
        url = "$STR_mod_URL";
        units[] = {};
        weapons[] = {};
        requiredAddons[] = {"cba_main","ace_main"};
        VERSION_CONFIG;
        authors[] = {"OverlordZorn [CVO]"};
    };
};
