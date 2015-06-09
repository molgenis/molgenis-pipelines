#MOLGENIS ppn=2 mem=1gb walltime=03:00:00

#string realignedBam
#string baitIntervals
#string baitIntervals_nonAutoChrX
#string indexFileDictionary
#string sample
#string intermediateDir
#string whichSex
#string tempDir
#string checkSexMeanCoverage

module load picard-tools
sleep 10

#make intervallist
if [ ! -f ${baitIntervals_nonAutoChrX} ] 
then
	cp ${indexFileDictionary} ${baitIntervals_nonAutoChrX}
	awk '{if ($0 ~ /^X/){print $0}}' ${baitIntervals} >> ${baitIntervals_nonAutoChrX}
fi

#Calculate coverage chromosome X 
java -jar $PICARD_HOME/CalculateHsMetrics.jar \
INPUT=${realignedBam} \
TARGET_INTERVALS=${baitIntervals_nonAutoChrX} \
BAIT_INTERVALS=${baitIntervals_nonAutoChrX} \
TMP_DIR=${tempDir} \
OUTPUT=${realignedBam}.nonAutosomalRegionChrX_hs_metrics

rm -rf ${sample}.checkSex.filter.meancoverage.txt

#select only the mean target coverage of the whole genome file
awk '{
        if ($0 ~ /^#/){

        }
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${realignedBam}.hs_metrics >> ${checkSexMeanCoverage}

#select only the mean target coverage of chromosome X
awk '{
        if ($0 ~ /^#/){

        }
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${realignedBam}.nonAutosomalRegionChrX_hs_metrics >> ${checkSexMeanCoverage}



perl -pi -e 's/\n/\t/' ${checkSexMeanCoverage}

RESULT=`awk '{
	if ( "NA" == $1 || "?" == $2 ){
		print "Unknown"
	} else {
		printf "%.2f \n", $2/$1 
	}
}' ${checkSexMeanCoverage}`

echo "RESULT: $RESULT"
awk '{
	
	if ( length($1) == 0){
		print "${realignedBam}.hs_metrics has not a MEAN TARGET COVERAGE value"
		exit 0
	}
	else if ( length($2) == 0 ){ 
		print "${realignedBam}.nonAutosomalRegionChrX_hs_metrics has not a MEAN TARGET COVERAGE value"
		exit 0
	}
	else if ( "NA" == $1 || "?" == $2 ) {
                print "Unknown"
        }
	else if ($2/$1 < 0.65 ){
                print $2," divided by ",$1," is less than 0.65 and this means that the coverage on chromosome X is 0.65 times less than the average coverage of the entire genome, this will most likely be a male";
                print "Male"

        }else if ($2/$1 > 0.85 ){
                print $2," divided by ",$1," is more than 0.85 and this means that the coverage on chromosome X is almost the same as the average coverage of the entire genome, this will most likely be a female";
                print "Female"
        }	
	else{
		print $2," divided by ",$1," is in between the 1.25 and 1.75, we are not sure what the sex is based on the coverage on chromosome X"
		print "Unknown" 
	}
}' ${checkSexMeanCoverage} >> ${whichSex}

