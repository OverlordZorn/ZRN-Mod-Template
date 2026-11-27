/*
* Author: Zorn
* Example suite: the mod is loaded. Replace or extend it with the mod's own suites,
* one file per feature (tests\fn_<name>.sqf), listed in description.ext >> CfgFunctions >> autotest_suite.
*
* A suite returns its tests: [ [name, code, timeout in s (default: 120)], ... ]. It runs nothing itself.
* Each test gets the suite's context hashmap (_ctx) - set something in one test, read it in a later one.
* Ids are numbered by order (T<suite>.<test>): add new tests at the end, so existing ids stay the same.
*
* Arguments:
* None
*
* Return Value:
* Tests <ARRAY>
*
* Example:
* [["example"]] spawn autotest_fnc_runAll;
*
* Public: No
*/

[
    ["CfgPatches of the mod", {
        params ["_ctx"];
        private _main = configFile >> "CfgPatches" >> "~PREFIX~_main";
        _ctx set ["main", _main];

        ["~PREFIX~_main exists", isClass _main] call autotest_fnc_check;
        ["has a version", getText (_main >> "versionStr") isNotEqualTo "", getText (_main >> "versionStr")] call autotest_fnc_check;
        ["needs CBA", "cba_main" in getArray (_main >> "requiredAddons"), true] call autotest_fnc_checkEqual;
    }],

    ["CBA settings ready", {
        params ["_ctx"];
        // needs another mod: skip when it is missing
        if !( isClass (configFile >> "CfgPatches" >> "cba_main") ) exitWith { ["CBA not loaded"] call autotest_fnc_skip };

        private _ready = [{ missionNamespace getVariable ["cba_settings_ready", false] }, 10] call autotest_fnc_waitFor;
        ["settings ready within 10 s", _ready] call autotest_fnc_check;
    }, 30]
]
