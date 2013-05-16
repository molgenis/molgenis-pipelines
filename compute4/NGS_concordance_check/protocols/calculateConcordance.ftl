#MOLGENIS walltime=01:00:00 nodes=1 cores=1 mem=4
#FOREACH externalSampleID

##Check inputs
getFile ${genotypeArrayVCF}
getFile ${mergedbam}
getFile ${mergedbamindex}

##Check if outputs exist
alloutputsexist "${verifyBamIDResultPrefix}.bestRG" 
${verifyBamIDResultPrefix}.bestSM \
${verifyBamIDResultPrefix}.depthRG \
${verifyBamIDResultPrefix}.depthSM \
${verifyBamIDResultPrefix}.selfRG \
${verifyBamIDResultPrefix}.selfSM \
${verifyBamIDResultPrefix}.log \
${verifyBamIDResultCSV}

##Run verifyBamID
${verifyBamID} \
--vcf ${genotypeArrayVCF} \
--bam ${mergedbam} \
--out ${verifyBamIDResultPrefix} \
--verbose \
--best \
--maxDepth 1000 \
--precise

##Create overview report of result
SELFCHIPMIX=$(tail -1 ${verifyBamIDResultPrefix}.selfSM | awk '{print $12}')
SELFFREEMIX=$(tail -1 ${verifyBamIDResultPrefix}.selfSM | awk '{print $7}')
SELFSEQID=$(tail -1 ${verifyBamIDResultPrefix}.selfSM | awk '{print $1}')
BESTCHIPMIX=$(tail -1 ${verifyBamIDResultPrefix}.bestSM | awk '{print $12}')
BESTFREEMIX=$(tail -1 ${verifyBamIDResultPrefix}.bestSM | awk '{print $7}')
BESTCHIPID=$(tail -1 ${verifyBamIDResultPrefix}.bestSM | awk '{print $3}')
SWAP="NO"

echo -e "$SELFSEQID,POSSIBLE_CONTAMINATION,POSSIBLE_SAMPLE_SWAP" > ${verifyBamIDResultCSV}
echo -en "SELF," >> ${verifyBamIDResultCSV}

#Function to compare floats
function fcomp() {
    awk -v n1=$1 -v n2=$2 'BEGIN{ if (n1<=n2) exit 0; exit 1}'
}

#Check selfSM file
#Check for sample contamination
# float number comparison
fcomp $SELFCHIPMIX 0.02
returnCode=$?
if [ $returnCode -eq 1 ];#SELFCHIPMIXgt0.02
then
    echo -en "YES," >> ${verifyBamIDResultCSV}
else
    #Check if free-mix also > 0.02
    fcomp $SELFFREEMIX 0.02
    returnCode=$?
    if [ $returnCode -eq 1 ];#SELFFREEMIXgt0.02
    then
        echo -en "YES," >> ${verifyBamIDResultCSV}
    else
        echo -en "NO," >> ${verifyBamIDResultCSV}
    fi
fi
    
#Check for sample swap
fcomp $SELFCHIPMIX 0.60
returnCode=$?
#Check chip-mix
if [ $returnCode -eq 1 ];#SELFCHIPMIXgt0.60
then
    fcomp $SELFCHIPMIX 1.05
    returnCode=$?
    if [ $returnCode -eq 0 ];#SELFFREEMIXlt1.05
    then
        #Check free-mix
        fcomp $SELFFREEMIX -0.05
        returnCode=$?
        if [ $returnCode -eq 1 ];#SELFFREEMIXgt-0.05
        then
            fcomp $SELFFREEMIX 0.40
            returnCode=$?
            if [ $returnCode -eq 0 ];#SELFFREEMIXlt0.40
            then
                echo -e "YES" >> ${verifyBamIDResultCSV}
                SWAP="$BESTCHIPID"
            fi
        else
            echo -e "NO" >> ${verifyBamIDResultCSV}
        fi
    else
        echo -e "NO" >> ${verifyBamIDResultCSV}
    fi
else
    echo -e "NO" >> ${verifyBamIDResultCSV}
fi


echo -en "BEST," >> ${verifyBamIDResultCSV}


#Check bestSM file
#Check for sample contamination
fcomp $BESTCHIPMIX 0.02
returnCode=$?
if [ $returnCode -eq 1 ];#BESTCHIPMIXgt0.02
then
    echo -en "YES," >> ${verifyBamIDResultCSV}
else
    #Check if free-mix also > 0.02
    fcomp $BESTFREEMIX 0.02
    returnCode=$?
    if [ $returnCode -eq 1 ];#BESTFREEMIXgt0.02
    then
        echo -en "YES," >> ${verifyBamIDResultCSV}
    else
        echo -en "NO," >> ${verifyBamIDResultCSV}
    fi
fi

#Check for best matching sample on array
echo $SWAP >> ${verifyBamIDResultCSV}


##Copy result files
putFile ${verifyBamIDResultPrefix}.bestRG
putFile ${verifyBamIDResultPrefix}.bestSM
putFile ${verifyBamIDResultPrefix}.depthRG
putFile ${verifyBamIDResultPrefix}.depthSM
putFile ${verifyBamIDResultPrefix}.selfRG
putFile ${verifyBamIDResultPrefix}.selfSM
putFile ${verifyBamIDResultPrefix}.log