#!/bin/bash

# Scripto - an aid for searching for text in a working directory
# Designed for use with bash shell scripts, Scripto may also work with other scripts
# 1) You enter text to find, and Scripto scans all files in the current directory;
# 2) Scripto then displays all occurences with file names and line numbers;
# 3) You can then select an instance and open the file at that line using your chosen text editor.

# Completely rewritten by Elizabeth Mills 29th April 2021
#
# This program is free software; you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# A copy of the GNU General Public License is available from:
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

source lister.sh

function ScriptoMain {
    
    local editor exit term ignore

    CallHeading

    # Editor name is first item in settings file (strip label text eg "Editor:nano)"
    editor="$(head -n 1 .scriptosettings | tail -n 1 | cut -d':' -f2)"
    exit="No"
    while [ $exit = "No" ]
    do
        CallMenu "Find Settings"
        case $GlobalResponse in
        1)  CallHeading
            GlobalCursorRow=5
            CallForm "Enter the text to search for: "
            term="$GlobalResult"
            GlobalCursorRow=$((GlobalCursorRow+2))
            CallForm "Ignore case? y/N : "
            ignore="$GlobalResult"
            ignore="${ignore,,}"                    # Ensure lower case
            
            rm temp.file
            Prep "$term" "$ignore"
        ;;
        2)  $editor .scriptosettings
        ;;
        *)  exit="Yes"
        esac
    done  
}

function Prep   # Prepare search data
{               # $1 search text; $2 ignore case (y)
    local text items i line filename linenumber width
    text="$1"

    width=$(tput cols)
    width=$((width-2))

    rm output.file temp.file                # Just to be sure

    if [ "$2" == "y" ]; then 
        grep -ins "$text" * >> temp.file    # Find all instances ignoring case
    else
        grep -ns "$text" * >> temp.file     # Find all instances observing case
    fi
    
    items=$(cat temp.file | wc -l)          # Count lines in file
        
    for (( i=1; i <= items; ++i )) 
    do
        line="$(head -n ${i} temp.file | tail -n 1)"            # Read one line at a time
        echo ${line##*( )} | cut -c 1-$width  >> output.file    # Remove all leading spaces
                                                                # And cut it down to fit width
    done

    rm temp.file

    # Now display the results
    while :   # User can repeat 
    do
        CallLongMenu output.file    # Display as a menu (may scroll off screen)
       
        if [ $? -eq 2 ]; then       # User is backing out (exit button pressed)
            rm output.file
            return 0
        else
            filename="$(echo $GlobalResult | head -n 1 | tail -n 1 | cut -d':' -f1)"
            linenumber="$(echo $GlobalResult | head -n 1 | tail -n 1 | cut -d':' -f2)"
            $editor $filename "+$linenumber"    # Open file in editor at chosen line
        fi
    done
}

Backtitle=" ~ Scripto - A Programmers' Utility ~ "
ScriptoMain
