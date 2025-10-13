#!/usr/bin/env python3

import os
import sys
from xml.dom import minidom

# STRINGTABLE DIAG TOOL
# Author: KoffeinFlummi
# ---------------------
# Checks for missing translations and all that jazz.

def get_all_languages(projectpath):
    """ Checks what languages exist in the repo. """
    languages = []

    for module in os.listdir(projectpath):
        if module[0] == ".":
            continue

        stringtablepath = os.path.join(projectpath, module, "stringtable.xml")
        try:
            xmldoc = minidom.parse(stringtablepath)
        except:
            continue

        keys = xmldoc.getElementsByTagName("Key")
        for key in keys:
            for child in key.childNodes:
                try:
                    if not child.tagName in languages:
                        languages.append(child.tagName)
                except:
                    continue

    return languages

def check_module(projectpath, module, languages):
    """ Checks the given module for all the different languages. """
    localized = []

    stringtablepath = os.path.join(projectpath, module, "stringtable.xml")
    try:
        xmldoc = minidom.parse(stringtablepath)
    except:
        return 0, localized

    keynumber = len(xmldoc.getElementsByTagName("Key"))

    for language in languages:
        localized.append(len(xmldoc.getElementsByTagName(language)))

    return keynumber, localized

def main():
    markdown = "--markdown" in sys.argv

    scriptpath = os.path.realpath(__file__)
    projectpath = os.path.dirname(os.path.dirname(scriptpath))
    projectpath = os.path.join(projectpath, "addons")

    if not markdown:
        print("#########################")
        print("# Stringtable Diag Tool #")
        print("#########################")

    languages = get_all_languages(projectpath)

    if not markdown:
        print("\nLanguages present in the repo:")
        print(", ".join(languages))

    keysum = 0
    localizedsum = [0 for _ in languages]
    missing = {lang: {} for lang in languages}  # module -> list of missing keys

    for module in os.listdir(projectpath):
        stringtablepath = os.path.join(projectpath, module, "stringtable.xml")
        try:
            xmldoc = minidom.parse(stringtablepath)
        except:
            continue

        keys = xmldoc.getElementsByTagName("Key")
        keynumber = len(keys)
        if keynumber == 0:
            continue

        keysum += keynumber

        for i, lang in enumerate(languages):
            localized_count = len(xmldoc.getElementsByTagName(lang))
            localizedsum[i] += localized_count
            if localized_count < keynumber:
                missing_keys = []
                for key in keys:
                    if not key.getElementsByTagName(lang):
                        missing_keys.append(key.getAttribute("name") or key.getAttribute("id") or "(unknown)")
                missing[lang][module] = missing_keys

    # --- Markdown Table ---
    print(f"**Translation Status Report**\n")
    print(f"_Total number of keys: {keysum}_\n")
    print("| Language | Missing Entries | Modules Missing Keys | % Complete |")
    print("|----------|----------------:|--------------------|------------|")
    for i, lang in enumerate(languages):
        percent_done = round(100 * localizedsum[i] / keysum) if keysum > 0 else 100
        missing_count = sum(len(v) for v in missing[lang].values())
        modules = ", ".join(missing[lang].keys()) if missing_count > 0 else "-"
        entry_display = f"**{missing_count} ⚠️**" if missing_count > 0 else "0"
        print(f"| {lang} | {entry_display} | {modules} | {percent_done}% |")

    # --- Collapsible Sections with Missing Keys ---
    for lang in languages:
        missing_count = sum(len(v) for v in missing[lang].values())
        if missing_count == 0:
            continue
        print(f"\n<details>")
        print(f"<summary>{lang} ({missing_count} missing)</summary>\n")
        for module, keys in missing[lang].items():
            print(f"- **{module}**: {', '.join(keys)}")
        print("</details>\n")

if __name__ == "__main__":
    main()
