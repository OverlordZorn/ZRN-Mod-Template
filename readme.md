# Initial Stuff

## Mod Framework
1. Fill Out `mod.cpp`
2. Fill Out `.hemtt\project.toml`

## Main Addon
1. Fill Out `addons\main\$PBOPREFIX$`
   1. `~MAINPREFIX~`
   2. `~PREFIX~`
2. Fill Out `addons\main\script_mod.hpp`
3. Update   `addons\main\script_version.hpp` when needed
4. Fill Out `addons\main\config.cpp`
5. Fill Out `addons\main\stringtable.xml`

## Template Addon
1. Rename Folder
2. Update `addons\~TEMPLATE_ADDON~\$PBOPREFIX$`
   1. `~MAINPREFIX~`
   2. `~PREFIX~`
   3. `~TEMPLATE_ADDON~`
3. Update `addons\~TEMPLATE_ADDON~\script_component.hpp`
4. Update `addons\~TEMPLATE_ADDON~\config.cpp`
   1. Component
   2. Component beautified
   3. path to `...\addons\main\script_mod.hpp`
   4. Path to `...\addons\main\script_macros.hpp`
5. Start building your mod
   1. Dont forget to remove fn_example.