#!/bin/sh
#string chr
#list chunk
#list just

for s in "${chunk[@]}"
do
    echo $s
    for j in "${just[@]}"
    do
        echo $j
    done
done