#!/bin/bash

getdata()
{
CLUSTER="cluster";
GRID="grid";

INPUT="input";
OUTPUT="output";
EXE="exe";

ARGS=($@)
BACKEND="${ARGS[0]}";
OPERATION="${ARGS[1]}";

NUMBER="${#ARGS[@]}";
MIN=4

if [ "$NUMBER" -gt "$MIN" ]
then

	for (( i=4; i<$#; i++ ))
	do
		value="${ARGS[2]}${ARGS[3]}${ARGS[$i]}";
		
		if [ "$BACKEND" == "$CLUSTER" ]
		then
			#check if data exists on the cluster
			if test ! -e $value;
	    		then
		  			echo "$value is missing" 1>&2
			fi
    	fi
    
    	if [ "$BACKEND" == "$GRID" ]
    	then
    		#download/upload data on the grid
    		if [ "$OPERATION" == "$INPUT" ]
    		then
    			lcg-cp lfn://grid$value file:///$TMPDIR${ARGS[3]}${ARGS[$i]}
    		fi

			if [ "$OPERATION" == "$OUTPUT" ]
    		then
    		lcg-cr -l lfn://grid$value file:///$TMPDIR/${INPUTS[2]}${INPUTS[$i]}
    		fi

			#download executable
			if [ "$OPERATION" == "$EXE" ]
    		then
    			lcg-cp lfn://grid$value file:///$TMPDIR${ARGS[3]}${ARGS[$i]}
    			chmod 755 $TMPDIR${ARGS[3]}${ARGS[$i]}
    		fi
		
    		#check sum on the execution node
    		echo -n "SUM_ADLER32_${ARGS[3]}${ARGS[$i]} "
			adler32 file:///$TMPDIR${ARGS[3]}${ARGS[$i]}
    	fi
	
	done

else

	if [ "$BACKEND" == "$CLUSTER" ]
	then
		#check if data exists on the cluster
		if test ! -e $value;
	    then
		  echo "$value is missing" 1>&2
		fi
    fi
    
    if [ "$BACKEND" == "$GRID" ]
    then
    	#download/upload data on the grid
    	if [ "$OPERATION" == "$INPUT" ]
    	then
    		lcg-cp lfn://grid$value file:///$TMPDIR${ARGS[3]}
    	fi

		if [ "$OPERATION" == "$OUTPUT" ]
    	then
    		lcg-cr -l lfn://grid$value file:///$TMPDIR/${INPUTS[2]}
    	fi

		#download executable
		if [ "$OPERATION" == "$EXE" ]
    	then
    		lcg-cp lfn://grid$value file:///$TMPDIR${ARGS[3]}
    		chmod 755 $TMPDIR${ARGS[3]}
    	fi

    	#check sum on the execution node
    	echo -n "SUM_ADLER32_${ARGS[3]}${ARGS[$i]} "
		adler32 file:///$TMPDIR${ARGS[3]}
    fi

fi

}


