<#noparse>#!/bin/bash
getFile()
{
    ARGS=($@)
    NUMBER="${#ARGS[@]}";
if [ "$NUMBER" -eq "1" ]
    then
    myFile=${ARGS[0]}

    if test ! -e $myFile;
	then
	echo "WARNING in getFile/putFile: $myFile is missing" 1>&2
	fi

    else
    echo "Example usage: getData \"\$TMPDIR/datadir/myfile.txt\""
    fi
}

putFile()
{
    `getFile $@`
}

export -f getFile
export -f putFile</#noparse>