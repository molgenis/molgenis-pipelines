#!/bin/bash

#convert.sh input.file output.file

awk '{printf "%s"",",$1}' FS="," $1 > $2
perl -pi -e 's/,$/\n/g' $2 
awk '{printf "%s"",",$2}' FS="," $1 >> $2
perl -pi -e 's/,$/\n/g' $2
