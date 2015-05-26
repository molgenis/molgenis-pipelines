#!/bin/sh
#string project
#string dir
#list sample
#list chr


for s in "${sample[@]}"
do
    echo $s
    for c in "${chr[@]}"
    do
         echo $c
    done
done