#!/bin/bash
#
# Rip Script for multi-mode CDs
#
# Usage: ./rip.sh [destination directory]
# Examples:
# ./rip.sh
#   - Runs with default settings, destination= current directory / disc's label, from /dev/cdrom (/dev/sr0)
#
# ./rip.sh /path/to/dumps
#   - Runs outputting to /path/to/dumps/disc's label, from from /dev/cdrom (/dev/sr0)

#Clean up variables
unset DIR
unset NAME
ERROR=0

# Check for dependencies
command -v cdrdao >/dev/null 2>&1 || { echo >&2 "Missing dependency: cdrdao.  Aborting."; ERROR=1; }
command -v toc2cue >/dev/null 2>&1 || { echo >&2 "Missing dependency: toc2cue.  Aborting."; ERROR=1; }

if [ "$ERROR" -eq 1 ] ; then 
        ERROR=0
        exit 1
    fi

# Build variables
# Get output directory
if [ -e "$1" ] ; then
    DIR=$1/
    else
    read -e -p "Enter output directory or press enter for current directory :" DIR
    fi
if [ -z "$DIR" ] ; then
    DIR=$(pwd)/
    fi

# Get CD-ROM label
NAME=$(file -s /dev/cdrom | awk -F\' '{print $(NF-1)}')

#build Output label
OUTPUT="$DIR$NAME/$NAME"

# Create destination directory
mkdir $DIR$NAME

# Verbosity
echo "CD-ROM Label:     $NAME"
echo "Output Directory: $DIR$NAME/"
echo "Outputs:          $OUTPUT.bin"
echo "                  $OUTPUT.cue"

# Rip CD-ROM
cdrdao read-cd --read-raw --datafile "$OUTPUT.bin" --driver generic-mmc:0x20000 --device /dev/cdrom "$OUTPUT.toc"
toc2cue "$OUTPUT.toc" "$OUTPUT.cue"

#Garbage collection
rm "$OUTPUT.toc"
eject /dev/cdrom