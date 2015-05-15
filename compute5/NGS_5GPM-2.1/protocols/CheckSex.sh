#MOLGENIS ppn=2 mem=1gb walltime=03:00:00

#string BQSRBam
#string baitIntervals
#string baitIntervals_nonAutoChrX
#string sample
#string intermediateDir
#string whichSex
#string tempDir
#string checkSexMeanCoverage

module load picard-tools


#make intervallist
if [ ! -f ${baitIntervals_nonAutoChrX} ] 
then
	head -85 ${baitIntervals} > ${baitIntervals_nonAutoChrX}
	awk '{if ($0 ~ /^X/){print $0}}' ${baitIntervals} >> ${baitIntervals_nonAutoChrX}
fi

#Calculate coverage chromosome X 
java -jar $PICARD_HOME/CalculateHsMetrics.jar \
INPUT=${BQSRBam} \
TARGET_INTERVALS=${baitIntervals_nonAutoChrX} \
BAIT_INTERVALS=${baitIntervals_nonAutoChrX} \
TMP_DIR=${tempDir} \
OUTPUT=${BQSRBam}.nonAutosomalRegionChrX_hs_metrics

rm -rf ${sample}.checkSex.filter.meancoverage.txt

#select only the mean target coverage of chromosome X 
awk '{
	if ($0 ~ /^#/){
	
	}
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${BQSRBam}.nonAutosomalRegionChrX_hs_metrics >> ${checkSexMeanCoverage}

#select only the mean target coverage of the whole genome file
awk '{
        if ($0 ~ /^#/){

        }
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${BQSRBam}.hs_metrics >> ${checkSexMeanCoverage}

perl -pi -e 's/\n/\t/' ${checkSexMeanCoverage}

awk '{
        if (int($1/$2) > 1.75 ){
                print $1," divided by ",$2," is more than 1.75 and this means that the coverage on chromosome X is 1.75 times less than the average coverage of the entire genome, this will most likely be a male";
		print "Male"
		
        }else if (int($1/$2) < 1.25 ){
                print $1," divided by ",$2," is less than 1.25 and this means that the coverage on chromosome X is almost the same as the average coverage of the entire genome, this will most likely be a female";
		print "Female"
        }
	else{
		print $1," divided by ",$2," is in between the 1.25 and 1.75, we are not sure what the sex is based on the coverage on chromosome X"
		print "Unknown" 
	}
}' ${checkSexMeanCoverage} >> ${whichSex}
