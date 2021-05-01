#!/bin/bash

# Scripto - an aid for searching for text in all text files in a directory
# Designed to help programmers find all references to a function or variable or other keywords
# 1) You enter the text to find, and Scripto scans all files in the current directory;
# 2) Scripto then displays all occurences of that text with file names and line numbers;
# 3) You can then select an instance and open the file at that line using your chosen text editor.

# Completely rewritten by Elizabeth Mills April 2021
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
    local editor terminal term ignore

    editor="$(head -n 1 .scriptosettings | tail -n 1 | cut -d':' -f2)"  
    terminal="$(head -n 2 .scriptosettings | tail -n 1 | cut -d':' -f2)"  
    
    while true
    do
        ScriptoInfo
        ScriptoFind
    done  
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
        *) DoFirstItem "Scripto is a programmer's utility for finding functions, variables, etc"
        esac
        GlobalCursorRow=$((GlobalCursorRow+1))
    done
}

function ScriptoMenu
{
    DoMenu "Find Settings"
    case $GlobalInt in
    1)  DoHeading
        ScriptoFind
    ;;
    2)  $editor .scriptosettings
        ScriptoMenu
    ;;
    *)  exit
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
        ignore="${GlobalChar,,}"        # Ensure lower case for option

        rm temp.file 2>/dev/null        # Clear the temp file (hide errors)
        ScriptoPrep "$term" "$ignore"   # Prepare data for DoMega to use for page handling
    done
}

function ScriptoPrep    # ScriptoPrepare search data
{                       # $1 search text; $2 ignore case (y/n)
    local term items i line filename linenumber width
    term="$1"
    width=$(tput cols)
    width=$((width-2))

    # temp.file is prepared with crude data for DoMega
    if [ "$2" == "y" ]; then 
        grep -ins "$term" * >> temp.file    # Find all instances ignoring case
    else
        grep -ns "$term" * >> temp.file     # Find all instances observing case
    fi
    
    # Now display the results, and user can select an item
    DoMega "temp.file" "$term"         # DoMega will handle diplay and user input
    rm output.file 2>/dev/null         # The work file - must be rebuilt
    if [ "$GlobalChar" != "" ]; then   # User is not backing out, then prepare for editing
        filename="$(echo $GlobalChar | head -n 1 | tail -n 1 | cut -d':' -f2)"    # -f1 is record number
        linenumber="$(echo $GlobalChar | head -n 1 | tail -n 1 | cut -d':' -f3)"
        $editor "$filename" "+$linenumber"   # Open the file in editor at chosen line
    fi
}

function DoMega   # Cleans up crude data from temp.file and prepares output.file
{   # Generates a (potentially multi-page) numbered list from a file
    # Parameter: $1 Name of the file containing all the items to be listed; $2 Search term
    local advise previous next instructions pages pageNumber width
    local winHeight items i counter line display startpoint saveCursorRow term
    term="$2"
    width=$(tput cols)
    width=$((width-2))
    items=$(cat $1 | wc -l)             # Count lines in file
    winHeight=$(tput lines)
    display=$((winHeight-6))            # Items to display in one pageful
    pages=$((items/display))
    if [ $pages -eq 0 ]; then pages=1; fi

    rm output.file 2>/dev/null  # Clear the work file (hide errors)

    # 1) Read the temp.file, number each item, shorten to fit page width and save to a new file
    for (( i=1; i <= items; ++i )) 
    do
        line="$(head -n ${i} temp.file | tail -n 1)"            # Read one line at a time
        line="$i:$line"                                         # Number it
        echo ${line##*( )} | cut -c 1-$width  >> output.file    # Remove all leading spaces
    done                                                        # and cut it down to fit width

    # Dump the source file, which has to be rebuilt each time
    rm temp.file 2>/dev/null  # Clear the temp file (hide errors)

    if [ $items -le $display ]; then    # DoLongMenu is more convenient for a single page
        DoLongMenu "output.file" "Ok Exit" "$term"
        return $?
    fi

    pageNumber=1                # Start at first page
    GlobalCursorRow=2
    counter=1                   # For locating items in the file

    DoMegaPage $pageNumber $pages $display $items $counter    # Prints the page

} # End DoMega

function DoMegaPage       # The actual printing bit
{                         # $1 pageNumber; $2 pages; $3 display; #4 items; $5 counter
    local advise previous next instructions pages pageNumber
    local winHeight items i counter line display startpoint saveCursorRow
    advise="Or ' ' to exit without choosing" 
    previous="Enter 'p' for previous page"
    next="'n' for next page"
    pageNumber=$1
    pages=$2
    display=$3
    items=$4
    counter=$5

    while true      # Print the actual page
    do
        if [ $pageNumber -eq 1 ]; then    
            instructions="Enter $next"
        elif [ $pageNumber -eq $pages ]; then  
            instructions="$previous"
        else
            instructions="$previous or $next"
        fi

        DoHeading           
        GlobalCursorRow=1
        DoFirstItem "Lines containing: '$term'"
        GlobalCursorRow=2
        DoFirstItem "Page $pageNumber of $pages"
        GlobalCursorRow=3         
        # Print a pageful up to max number of lines to display
        for (( line=1; line <= $display; ++line ))
        do
            item=$(head -n $counter output.file | tail -1)  # Read item from file     
            if [ $line -eq 1 ]; then                        # First item on this page
                tput cup $GlobalCursorRow 2                 # Move cursor to startpoint
                printf "%-s\\v" "$item"                     # Print the item
            else
                DoNextItem 2 "$item"
            fi       
            counter=$((counter+1)) 
            if [ $counter -gt $items ]; then                # Exit loop if last record
                GlobalCursorRow=$((GlobalCursorRow+1)) 
                break
            fi
            GlobalCursorRow=$((GlobalCursorRow+1)) 
        done
        DoFirstItem "$instructions"             
        DoFirstItem "$advise"
        DoForm "Enter the number of your selection : "

        case "$GlobalChar" in                        
        'p'|'P') if [ $pageNumber -ne 1 ]; then             # Ignore illegal call to previous page
                pageNumber=$((pageNumber-1))
            fi
         ;;
        'n'|'N') if [ $pageNumber -ne $pages ]; then        # Ignore illegal call to next page
                pageNumber=$((pageNumber+1))
            fi
        ;;
        *[!0-9]*) # Other characters that are not numbers
            if [ "$GlobalChar" == "" ]; then                 # User backing out
                return 0
            fi
        ;;
        *)  # A number was entered
            counter="$GlobalChar"   # Convert char to int and use to find the item in the file
            GlobalChar="$(head -n ${counter} output.file | tail -n 1)"
            return 0
        esac
        counter=$(((pageNumber*display)+1-display))
    done
} # End DoMegaPage

Backtitle=" ~ Scripto - A Programmers' Utility ~ "
ScriptoMain
