#!/bin/bash

# Scripto - an aid for searching for text in all text files in a directory
# Designed to help programmers find all references to a function or variable or other keywords
# 1) You enter the text to find, and Scripto scans all files in the current directory;
# 2) Scripto then displays all occurences of that text with file names and line numbers;
# 3) You can then select an instance and open the file at that line using your chosen text editor.

# Revision 210510
# Elizabeth Mills
#
# This program is free software; you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# A copy of the GNU General Public License is available from:
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

source lister.sh    # User interfaces

GlobalInt=0
GlobalChar=""
GlobalCursorRow=0 

function ScriptoMain
{
    local editor terminal exclude term ignore

    editor="$(head -n 1 scripto.settings | tail -n 1 | cut -d':' -f2)"  
    terminal="$(head -n 2 scripto.settings | tail -n 1 | cut -d':' -f2)"
    
    while true
    do
        Tidy                    # Clean up work area on arrival
        DoHeading
        ScriptoFind
        Tidy                    # Clean up work area before leaving
    done  
}

function Tidy
{
    rm scripto-temp.file 2>/dev/null        # Clear the temp file (hide errors)
    rm scripto-exclude.file 2>/dev/null    # Clear the temp file (hide errors)
}

function ScriptoInfo    # ScriptoPrepares page and prints helpful comments
{                       # $1 String of integers
    local item items
    items=$(echo $1 | wc -l)     # Count lines in $1
    for item in $1
    do
        case $item in
        1) DoFirstItem "Scripto will search all files in the current directory for text matching"
        ;;
        2) DoFirstItem "your criteria, and will list each line onscreen for you to choose one."
        ;;
        3) DoFirstItem "The selected item will then be opened in your nominated editor."
        ;;
        4) DoFirstItem "Enter any text to search, or leave empty and [Enter] for a menu."
        ;;
        *) DoFirstItem "Unexpected item in the bagging area!"
        esac
        GlobalCursorRow=$((GlobalCursorRow+1))
    done
}

function ScriptoMenu
{
    DoMenu "Find Settings" "" "Search, change settings, or quit"
    case $GlobalInt in
    1)  DoHeading
        ScriptoFind
        Tidy
    ;;
    2)  $editor scripto.settings         # Then reload in current session ...
        editor="$(head -n 1 scripto.settings | tail -n 1 | cut -d':' -f2)"  
        terminal="$(head -n 2 scripto.settings | tail -n 1 | cut -d':' -f2)"
        exclude="$(head -n 3 scripto.settings | tail -n 1 | cut -d':' -f2)"
        ScriptoMenu
    ;;
    *)  Tidy
        exit
    esac
}

function ScriptoFind
{
    local term ignore
    
    while true      # Get user input
    do
        DoHeading
        GlobalCursorRow=4
        ScriptoInfo "4"
        GlobalCursorRow=9
        ScriptoInfo "1 2 3"

        GlobalCursorRow=5
        DoForm "Enter the text to search for: "
        
        if [ "$GlobalChar" == "" ]; then ScriptoMenu; fi
        term="$GlobalChar"
        
        GlobalCursorRow=$((GlobalCursorRow+2))
        DoForm "Ignore case? y/N : "
        ignore="${GlobalChar,,}"        # Ensure lower case for y/n option

        Tidy                            # Clean up work area
        ScriptoPrep "$term" "$ignore"   # Prepare data for DoMega to use for page handling
        Tidy                            # And clean again on return
    done
}

function ScriptoPrep    # ScriptoPrepare search data
{                       # $1 search text; $2 ignore case (y/n)
    local term items i line filename linenumber width ignore
    term="$1"
    ignore="$2"
    
    while true
    do  
        width=$(tput cols)
        width=$((width-2))
        Tidy                                # Clean up work area before starting
        # Prepare scripto-exclude.file
        exclude="$(head -n 3 scripto.settings | tail -n 1 | cut -d':' -f2)"
        for item in $exclude
        do
            echo $item >> scripto-exclude.file
        done

        # Prepare scripto-temp.file with crude data for DoMega
        if [ "$ignore" == "y" ]; then 
            grep -ins "$term" * | grep -v -f scripto-exclude.file >> scripto-temp.file    # Find all instances ignoring case
        else
            grep -ns "$term" * | grep -v -f scripto-exclude.file >> scripto-temp.file     # Find all instances observing case
        fi

        items=$(cat scripto-temp.file | wc -l)         # Count lines in file
        if [ $items -eq 0 ]; then
            DoMessage "No matches found for '$term'"
            return
        fi

        # Now display the results, and user can select an item
        DoMega "scripto-temp.file" "Items found matching : '$term'" # DoMega will handle diplay and user input
        Tidy                                # Clean up work area upon return
        if [ "$GlobalChar" == "" ]; then                # User is backing out
            return
        else                                            # Prepare for editing
            filename="$(echo $GlobalChar | head -n 1 | tail -n 1 | cut -d':' -f2)"    # -f1 is record number
            linenumber="$(echo $GlobalChar | head -n 1 | tail -n 1 | cut -d':' -f3)"
            case ${editor,,} in
            'kate') kate "-l$linenumber" "$filename"
            ;;
            'netbeans') netbeans "${filename}:$linenumber"
            ;;
            *)  $editor "+$linenumber" "$filename"         # Open the file in editor at chosen line
            esac
        fi
    done
}

Backtitle=" ~ Scripto - A Programmers' Utility ~ "
ScriptoMain
