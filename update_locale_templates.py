#!/usr/bin/env python3
# -*- coding: utf-8 -*-

##########################################################################
##### ABOUT THIS SCRIPT ##################################################
# This script updates the translation template files (*.pot) of all mods
# by running the xgettext application.
# It requires you have the 'gettext' software installed on your system.
#
# Run this script, and the *.pot files will be updated.
##########################################################################



# e-mail address to send problems with the original strings ("msgids") to
MSGID_BUGS_ADDRESS = "Wuzzy@disroot.org"
# name of the package
PACKAGE_NAME = "Repixture"

import os
import re

# pattern for the 'name' in mod.conf
pattern_name = re.compile(r'^name[ ]*=[ ]*([^ \n]*)')
# file name pattern for gettext translation template files (*.pot)
pattern_pot = re.compile(r'(.*)\.pot$')

def invoke_xgettext(template_file, mod_folder, modname):
    containing_path = os.path.dirname(template_file)
    lua_files = [os.path.join(mod_folder, "*.lua")]
    for root, dirs, files in os.walk(os.path.join(mod_folder)):
       for dirname in dirs:
           if dirname != "sounds" and dirname != "textures" and dirname != "models" and dirname != "locale" and dirname != "media" and dirname != "schematics":
               lua_path = os.path.join(mod_folder, dirname)
               lua_files.append(os.path.join(lua_path, "*.lua"))

    lua_search_string = " ".join(lua_files)

    command = "xgettext -L lua -kS -kNS -kFS -kNFS -kPS:1,2 -kcore.translate:1c,2 -kcore.translate_n:1c,2,3 -d '"+modname+"' --add-comments='~' -o '"+template_file+"' --from-code=UTF-8 --msgid-bugs-address='"+MSGID_BUGS_ADDRESS+"' --package-name='"+PACKAGE_NAME+"' "+lua_search_string

    return_value = os.system(command)
    if return_value != 0:
        print("ERROR: xgettext invocation returned with "+str(return_value))
        exit(1)

def update_locale_template(folder, modname):
    for root, dirs, files in os.walk(os.path.join(folder, 'locale')):
        for name in files:
            code_match = pattern_pot.match(name)
            if code_match == None: 
                continue
            fname = os.path.join(root, name)
            invoke_xgettext(fname, folder, modname)

def get_modname(folder):
    try:
        with open(os.path.join(folder, "mod.conf"), "r", encoding='utf-8') as mod_conf:
            for line in mod_conf:
                match = pattern_name.match(line)
                if match:
                    return match.group(1)
    except FileNotFoundError:
        if not os.path.isfile(os.path.join(folder, "modpack.txt")):
            folder_name = os.path.basename(folder)
            return folder_name
        else:
            return None
    return None

def update_mod(folder):
    modname = get_modname(folder)
    if modname != None:
       print("Updating '"+modname+"' ...")
       update_locale_template(folder, modname)

def main():
    for modfolder in [f.path for f in os.scandir("./mods") if f.is_dir() and not f.name.startswith('.')]:
        is_modpack = os.path.exists(os.path.join(modfolder, "modpack.txt")) or os.path.exists(os.path.join(modfolder, "modpack.conf"))
        if is_modpack:
            subfolders = [f.path for f in os.scandir(modfolder) if f.is_dir() and not f.name.startswith('.')]
            for subfolder in subfolders:
                update_mod(subfolder)
        else:
            update_mod(modfolder)
    print("All done.")

main()
