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
    - simple Editor Test Mission `test.VR` to be used with `hemtt launch test`
  - hemtt's lints.toml

- GITHUB
  - `Release: Drafter` - drafts the next release (`v$NEXT_PATCH_VERSION`) from merged PRs, sorted by their `pr/*` labels
  - `Github: Require Label` - every PR needs at least one label (so the drafter can sort it)
  - `Release: Publish to Steam` / `[DEV]` - (disabled by default, see comments in the files)
    - sets MAJOR.MINOR.PATCH in `script_version.hpp` from the release tag
    - sets `_DEV_VERSION_` in `addons\main\debug_mode.hpp` to `1` (dev) or `0` (stable)
    - creates `meta.cpp`, builds via hemtt and attaches the .zip to the Github Release
    - Updates the Existing Steam Workshop Item, using the release notes as changelog
      - Requires Steam Account that Owns Arma3. It is strongly advised to aquire a secondary account if you wish to use the release->Steamworkshop feature
  - `Release: Discord Notice` - (disabled by default) posts the release notes to discord via webhook
  - `Validate: Config` / `Validate: HEMTT` - on push & PR
  - `Github: Translation Issue` - on stringtable changes, keeps a "Translations" issue updated with the `hemtt ln coverage` report (creates the issue if needed)
  - `Github: Sync Labels` - run manually, applies the labels from `.github\labels.yml` to the repo (optionally removes all unlisted labels)

- TOOLS - used by the workflows above
  - `validate_config.py` - config style checks (tabs, brackets, class formatting)
  - `sync_labels.py` - applies `.github\labels.yml`
  - `update-version.ps1` / `create-meta-cpp.ps1` - set the version and create `meta.cpp` during the Steam release

- Automated Version Bumping
  - BUILD on `hemtt build`, including `hemtt launch`
  - MAJOR.MINOR.PATCH from the release tag when releasing through the github action



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
5. Update `addons\main\stringtable.xml` - `author` and `url` are used by every addon's `CfgPatches` via `ECSTRING(main,author)` / `ECSTRING(main,url)`

#### Github Repo
1. Add the `pr/*` labels (needed by `Release: Drafter` and `Github: Require Label`): Actions tab -> `Github: Sync Labels` -> Run workflow
   - first run with `Dry run` ticked to see what would change
   - set `remove_unlisted: true` in `.github\labels.yml` to also remove githubs default labels
2. Optional: set up and enable the `release-*.yml` workflows (Steam / Discord)

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

## How to install Hemtt
`winget install BrettMayson.HEMTT` to install.

### Update Hemtt
`winget upgrade BrettMayson.HEMTT` to update.

### Install Winget
https://learn.microsoft.com/en-us/windows/package-manager/winget/
