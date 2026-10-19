[h1]Overlord Zorns Personal Mod Template[/h1]
Here I maintain a personal, basic mod framework.

Feel free to create a PR if you see something missing!

[h2]This Arma3 Mod Template comes with:[/h2]
[list]
[*]MAIN ADDON
[list]
[*]Has a set of my personal macros. Some are somewhat duplicate from cba, but i already got used to them. Feel free to use them or not.
[/list]
[*]DEFAULT ADDON - new addons are created with tools\new-addon.bat from [url=https://github.com/CVO-Org/ZRN-Mod-Template-Default-Addon]ZRN-Mod-Template-Default-Addon[/url]
[list]
[*]Basic CfgFunctions Setup
[list]
[*]example fn_example.sqf function
[/list]
[*]Basic CBA XEH Setup
[list]
[*]example XEH_preInit.sqf with CBA Addon Option Template
[/list]
[/list]
[*]INCLUDE Folder
[list]
[*]CBA Macros and Stuff
[*]ACE3 Macros and Stuff
[*]some A3 GUI Stuff
[/list]
[*]HEMTT
[list]
[*]hemtt's project.toml
[*]hemtt's launch.toml
[list]
[*]simple Editor Test Mission test.VR to be used with hemtt launch test
[/list]
[*]hemtt's lints.toml
[/list]
[*]GITHUB
[list]
[*]Release: Drafter - drafts the next release (v$NEXT_PATCH_VERSION) from merged PRs, sorted by their pr/* labels
[*]Github: Require Label - every PR needs at least one label (so the drafter can sort it)
[*]Release: Publish to Steam / [noparse][DEV][/noparse] - (disabled by default, see comments in the files)
[list]
[*]sets MAJOR.MINOR.PATCH in script_version.hpp from the release tag
[*]sets _DEV_VERSION_ in addons\main\debug_mode.hpp to 1 (dev) or 0 (stable)
[*]creates meta.cpp, builds via hemtt and attaches the .zip to the Github Release
[*]Updates the Existing Steam Workshop Item, using the release notes as changelog
[list]
[*]Requires Steam Account that Owns Arma3. It is strongly advised to aquire a secondary account if you wish to use the release->Steamworkshop feature
[/list]
[/list]
[*]Release: Discord Notice - (disabled by default) posts the release notes to discord via webhook
[*]Validate: Config / Validate: HEMTT - on push & PR
[*]Github: Translation Issue - on stringtable changes, keeps a "Translations" issue updated with the hemtt ln coverage report (creates the issue if needed)
[*]Github: Sync Labels - run manually, applies the labels from .github\labels.yml to the repo (optionally removes all unlisted labels)
[/list]
[*]TOOLS
[list]
[*]new-addon.bat / new-addon.ps1 - creates a new addon from the default addon, see Per New Addon
[*]readme-workshop.bat / readme-workshop.ps1 - converts README.md into a Steam Workshop description, see Steam Workshop Description
[*]validate_config.py - config style checks (tabs, brackets, class formatting)
[*]sync_labels.py - applies .github\labels.yml
[*]update-version.ps1 / create-meta-cpp.ps1 - set the version and create meta.cpp during the Steam release
[/list]
[*]Automated Version Bumping
[list]
[*]BUILD on hemtt build, including hemtt launch
[*]MAJOR.MINOR.PATCH from the release tag when releasing through the github action
[/list]
[/list]

[h2]HOW TO SETUP[/h2]
[h3]Once Per Mod[/h3]
[h3]Use VSCode Find and Replace across the whole repository[/h3]
[olist]
[*]replace PLACEHOLDER: ~MAINPREFIX~ with desired MAINPREFIX, example: x
[*]replace PLACEHOLDER: ~PREFIX~ with desired PREFIX, example ABE
[/olist]

[h3]Update the following files according to your needs[/h3]
[olist]
[*]mod.cpp
[*].hemtt\project.toml
[/olist]

[h3]Update the Main Addon[/h3]
[olist]
[*]Check $PBOPREFIX$
[*]Update addons\main\script_mod.hpp
[*]Update addons\main\script_version.hpp when needed
[*]Update addons\main\config.cpp
[*]Update addons\main\stringtable.xml - author and url are used by every addon's CfgPatches via ECSTRING(main,author) / ECSTRING(main,url)
[/olist]

[h3]Github Repo[/h3]
[olist]
[*]Add the pr/* labels (needed by Release: Drafter and Github: Require Label): Actions tab -> Github: Sync Labels -> Run workflow
[list]
[*]first run with Dry run ticked to see what would change
[*]set remove_unlisted: true in .github\labels.yml to also remove githubs default labels
[/list]
[*]Optional: set up and enable the release-*.yml workflows (Steam / Discord)
[/olist]

[h3]Per New Addon[/h3]
[h3]Run the new addon script[/h3]
Double-click tools\new-addon.bat, or run it from a terminal in the repository root (e.g. in VSCode):

[code]
tools\new-addon.bat
[/code]

It asks for:

[olist]
[*]the addon name, like common or my_addon - only lowercase letters, digits and _
[*]the display name (COMPONENT_BEAUTIFIED), suggested from the addon name
[*]the author, suggested from your git user name
[/olist]

MAINPREFIX and PREFIX are read from .hemtt\project.toml, so the mod has to be set up first. The script downloads the default addon from [url=https://github.com/CVO-Org/ZRN-Mod-Template-Default-Addon]ZRN-Mod-Template-Default-Addon[/url] (branch main), so every mod starts from the same default, fills it in and creates addons\<name>. Nothing outside that folder is touched.

Options:

[list]
[*]-Name, -DisplayName, -Author - skip the questions, e.g. tools\new-addon.bat -Name my_addon -DisplayName "My Addon" -Author "Zorn"
[*]-TemplateDir <path> - use a local template folder instead of downloading it
[*]-TemplateRepo <owner/repo> / -TemplateRef <branch or tag> - download the template from somewhere else
[/list]

[h3]Then[/h3]
[olist]
[*]Update addons\<name>\config.cpp - requiredAddons[], units[], weapons[] and other entries where needed
[*]Start building your mod
[olist]
[*]Dont forget to remove fn_example.
[/olist]
[/olist]

[h3]Changing the default addon[/h3]
The default addon lives in the addon folder of [url=https://github.com/CVO-Org/ZRN-Mod-Template-Default-Addon]ZRN-Mod-Template-Default-Addon[/url]. Its placeholders are {{MAINPREFIX}}, {{PREFIX}}, {{ADDON}}, {{ADDON_BEAUTIFIED}} and {{AUTHOR}}. Changes are used by every mod as soon as they are merged into its main.

[h3]Steam Workshop Description[/h3]
Double-click tools\readme-workshop.bat, or run it from a terminal in the repository root:

[code]
tools\readme-workshop.bat
[/code]

It converts README.md into README_workshop.txt, written in the BBCode the Steam Workshop description uses. Copy its content into the description of the workshop item.

[list]
[*]Headings, bold / italic / strikethrough, links, images, lists, code blocks, quotes, GitHub alerts (> [!IMPORTANT]), tables and horizontal rules are converted.
[*]Relative links and images point to the GitHub repository (from the origin remote) on branch main.
[*]Images Steam can't show (SVG, like shields.io badges) are replaced by their alt text, so a badge link stays a link.
[*]Lines of a paragraph are joined, like GitHub shows them. -KeepLineBreaks keeps every line break.
[*]Steam descriptions are limited to 8000 characters, the script warns when the result is longer.
[/list]

Parts of the readme can be left out or added only for the workshop:

[code]
<!-- workshop-skip -->
## Building from source
Only shown on GitHub.
<!-- /workshop-skip -->

<!-- workshop-only Only shown on the workshop, like a link back to the [GitHub Repository](https://github.com/...) -->
[/code]

Options:

[list]
[*]-Path <readme> / -OutFile <file> - convert another file, like an addon's readme
[*]-Repo <owner/repo> / -Branch <branch> - where relative links point to
[/list]

[h2]How to install Hemtt[/h2]
winget install BrettMayson.HEMTT to install.

[h3]Update Hemtt[/h3]
winget upgrade BrettMayson.HEMTT to update.

[h3]Install Winget[/h3]
https://learn.microsoft.com/en-us/windows/package-manager/winget/
