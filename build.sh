#!/bin/bash

set -e

OUTDIR=/output

green() {
    echo -ne "\e[32m"
    echo -n "$1"
    echo -e "\e[0m"
}

red() {
    echo -ne "\e[31m"
    echo -n "$1"
    echo -e "\e[0m"
}

task() {
    local OUTPUT
    echo -n "$1..."
    shift
    if OUTPUT=`("$@" 2>&1)`
    then
        green " ok"
        return 0
    else
        red " FAILED"
        echo "$OUTPUT"
        return 1
    fi
}


echo "Building Freenet updater"

task "Checking if output directory is writable" \
    test -w $OUTDIR
task "Building updater" \
    wine32 "c:\Python2.7\Scripts\pyinstaller.exe" --onefile  "z:/output/update.py"
task "Finishing" \
    mv dist/update.exe $OUTDIR/
