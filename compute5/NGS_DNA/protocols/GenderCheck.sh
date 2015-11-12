#MOLGENIS ppn=4 mem=6gb walltime=03:00:00

#string dedupBam
#string capturedIntervals
#string capturedIntervals_nonAutoChrX
#string indexFileDictionary
#string sample
#string intermediateDir
#string whichSex
#string tempDir
#string checkSexMeanCoverage
#string picardJar
#string hsMetricsNonAutosomalRegionChrX

module load picard
sleep 5

#select only the mean target coverage of the whole genome file
awk '{
        if ($0 ~ /^#/){

        }
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${dedupBam}.hs_metrics >> ${checkSexMeanCoverage}

#select only the mean target coverage of chromosome X
awk '{
        if ($0 ~ /^#/){

        }
        else if ($22 == ""){

        }else if ( $22 == "MEAN_TARGET_COVERAGE" ){

        }else{
                print $22
        }
}' ${hsMetricsNonAutosomalRegionChrX} >> ${checkSexMeanCoverage}



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
		print "${dedupBam}.hs_metrics has not a MEAN TARGET COVERAGE value"
		exit 0
	}
	else if ( length($2) == 0 ){ 
		print "${dedupBam}.nonAutosomalRegionChrX_hs_metrics has not a MEAN TARGET COVERAGE value"
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

