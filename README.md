# Scripto

So, you're a programmer, and you're uncertain about the syntax or usage of a function, or you have declared a variable ... somewhere ... but you can't remember where, or maybe you wrote a routine, and don't know if it ever got used. That's what **Scripto** is for.

**Scripto** is a utility for finding keywords buried in a large file or across several files. Its aim is to help developers search programs, help files and text-based manuals for key code, references to the usage and meaning of functions or reserved words and programming terms.

You might know the name of a function, or perhaps what it does - just enter what you think, and **Scripto**
will list every line in every file where your word appears, making it (hopefully) easy to find what you are looking for. Items in the list are grouped by the file in which they were found, and displayed in line-number order, so you can see how they relate.

<u>Application</u>

Although originally designed for use with bash shell scripts, **Scripto** has been rewritten to work with any plain text files for any purpose in a Linux environment. If you are a programmer, the ideal situation for **Scripto** would be in your workshop directory.

Is your source file huge, or is your code spread over several files? **Scripto** may help with visualising or debugging.

 1. You enter the text to find, and **Scripto** searches for it in all files in the current directory;
 2. **Scripto** then displays all occurences, with file names and line numbers;
 3. You can then select one and your chosen text editor will open the file at that line.

Note that **Scripto** sources the **Lister** library of simple interfaces, written for use in a text-based environment, so make sure that a copy of lister.sh is also present in your working directory. A copy of **Lister** is distributed with Scripto for your convenience. The current version of lister.sh was advanced to 2.00 on 2021/08/25, and Scripto now ships with this version.

**Scripto** is kept as basic as possible - you're a programmer, you know what to do.

Note that not all editors support the line-finding facility. Where they do, I have tried to include their syntax in Scripto:

 * Emacs, Geany, Gedit, Kate, Nano, Netbeans, Vi and Vim are among those that do;
 * Bluefish, CodeBlocks, Mousepad and xedit are among those that don't (as far as I know at the time of writing this).

If you use one that does not support line-finding, **Scripto** will still work, and will still
try to open your editor, but it won't open at the selected line.

<u>Settings</u>

There are three settings that you can change - your preferred editor, your terminal emulator, and any keywords you want excluded from the results of your search. User-maintained settings are retained in a file called Scripto.settings, which you can edit externally as desired, or from within **Scripto** by selecting Settings from the menu.

Each item has a label (eg: Editor:nano). Only edit after the colon - do not delete the label or the colon. They start from line 1 of the file, and must stay there in this order.

    Editor:nano
    Terminal:xterm
    Exclude:README

Add any new 'Exclude' items in a space-separated list after the 'Exclude:' label, all on one line. Regular expressions will probably not work.

The program described herein is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. A copy of the GNU General Public License is available from:
The Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Scripto is free software; you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

Elizabeth Mills 20230916
