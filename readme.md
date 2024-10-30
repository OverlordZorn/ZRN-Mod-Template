# Overlord Zorns Personal Mod Template

Here I maintain a personal, basic mod framework.

Feel free to create a PR if you see something missing!

## This Arma3 Mod Template comes with:

- MAIN ADDON
  - Has a set of my personal macros. Some are somewhat duplicate from cba, but i already got used to them. Feel free to use them or not.

- TEMPLATE ADDON Folder
  - Basic CfgFunctions Setup
    - example `fn_example.sqf` function
  - Basic CBA XEH Setup
    - example `XEH_preInit.sqf` with CBA Addon Option Template

- INCLUDE Folder
  - CBA Macros and Stuff
  - ACE3 Macros and Stuff
  - some A3 GUI Stuff

- HEMTT
  - hemtt's project.toml
  - hemtt's launch.toml
    - simple Editor Test Mission `test.vr` to be used with `hemtt launch Test`

- GITHUB
  - Github Action on release
    - create and rename .zip files for the Github Release Page
    - Update Existing Steam Workshop Files directly from the Github Release
      - Requires Steam Account that Owns Arma3. It is strongly advised to aquire a secondary account if you wish to use the release->Steamworkshop feature
    - Planned: Bump Patch Version on PR Merge
    - Planned: Bump Minor Version on Release, set patch to 0
  - SQF Validator Python Script


- Automated Version Bumping
  - MINOR on `hemtt release` (WIP: Only bumps when using on your local mashine through hemtt, not when releasing through github action.)
  - PATCH on github PR (PLANNED, not done yet - need to learn github action stuff first)
  - BUILD on `hemtt built`, including `hemtt launch`



## HOW TO SETUP

### Once Per Mod

#### Use VSCode Find and Replace across the whole repository
1. replace PLACEHOLDER: `~MAINPREFIX~` with desired MAINPREFIX, example: `x`
2. replace PLACEHOLDER: `~PREFIX~` with desired PREFIX, example `ABE`

#### Update the following files according to your needs
1. `mod.cpp`
2. `.hemtt\project.toml`

#### Update the Main Addon
1. Check `$PBOPREFIX$`
2. Update `addons\main\script_mod.hpp`
3. Update `addons\main\script_version.hpp` when needed
4. Update `addons\main\config.cpp`
5. Update `addons\main\stringtable.xml`

### Per New Addon

#### Choose a suitable name for the addon.
Examples are `common` or `my_addon`

> [!IMPORTANT]
> Ensure only lowercase is used in addon name! Especially important for the foldername.
> Building with hemtt through github will cause issues if uppercase is used!

#### Use VSCode Find and Replace
1. replace PLACEHOLDER: `~TEMPLATE_ADDON~` with desired Addon Name.

#### Update the following files according to your needs
##### Template Addon
1. Rename Folder accordingly, like `common` or `my_addon`. only lowercase!
2. Check `$PBOPREFIX$` should say something like `x\abe\addons\my_addon`
3. Check and Update `script_component.hpp`
   1. check and update `COMPONENT` and `COMPONENT_BEAUTIFIED` if needed
   2. check both `#includes`
4. Update `addons\~TEMPLATE_ADDON~\config.cpp`
   - update `authors[] = {};`
   - update other entries where needed.

5. Start building your mod
   1. Dont forget to remove fn_example.
