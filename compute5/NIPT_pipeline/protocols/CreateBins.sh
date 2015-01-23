#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string samtoolsVersion
#string bedtoolsVersion
#string dedupBam
#string tempDir
#string intermediateDir
#string tmpForwardBins
#string forwardBins
#string tmpReverseBins
#string reverseBins
#string anacondaVersion
#string strand
#string tmpBedForward
#string tmpBedReverse
#string RVersion
#string RScript
#string binsPdfReverse
#string binsPdfForward



#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "bedtoolsVersion: ${bedtoolsVersion}"
echo "samtoolsVersion: ${samtoolsVersion}"
echo "dedupBam: ${dedupBam}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "tmpForwardBins: ${tmpForwardBins}"
echo "forwardBins: ${forwardBins}"
echo "tmpReverseBins: ${tmpReverseBins}"
echo "reverseBins: ${reverseBins}"
echo "anacondaVersion: ${anacondaVersion}"
echo "strand: ${strand}"
echo "tmpBedForward: ${tmpBedForward}"
echo "tmpBedReverse: ${tmpBedReverse}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScript}"
echo "binsPdfReverse: ${binsPdfReverse}"
echo "binsPdfForward: ${binsPdfForward}"


sleep 10

#Check if output exists


if [ ${strand} == "forward" ]
then
	alloutputsexist \
	"${forwardBins}" 

else	
	alloutputsexist \
	"${reverseBins}" 
fi

#Get BAM file and reference data
getFile ${dedupBam}

#Load samtools module
${stage} samtools/${samtoolsVersion}


#load R module
${stage} R/${RVersion}
${checkStage}

#load bedtools module
${stage} bedtools/${bedtoolsVersion}
${checkStage}

#load anaconda module
${stage} anaconda/${anacondaVersion}
${checkStage}



if [ ${strand} == "forward" ]
then
	samtools \
	view -F 1040 \
	-h -u \
	${dedupBam} | bedtools bamtobed \
	> ${tmpBedForward}
	
	Rscript \
	${RScript} \
	--input ${tmpBedForward} \
	-p ${binsPdfForward} \
	-o ${tmpForwardBins}
	
	rm ${tmpBedForward}	
	
	#Get return code from last program call
	returnCode=$?

	
	echo -e "\nreturnCode CreateBinsForward: $returnCode\n\n"
	if [ $returnCode -eq 0 ]
	then
  		echo -e "\nCreateBins finished succesfull. Moving temp files to final.\n\n"
  	  	mv ${tmpForwardBins} ${forwardBins}
    	putFile "${forwardBins}"
    
    
	else
   		echo -e "\nFailed to move CreatebinsForward results to ${intermediateDir}\n\n"
    	exit -1
	fi

else	
	
	samtools \
	view -f 16 -F 1024 \
	-h -u \
	${dedupBam} | bedtools bamtobed \
	> ${tmpBedReverse}
	
	Rscript \
	${RScript} \
	--input ${tmpBedReverse} \
	-p ${binsPdfReverse} \
	-o ${tmpReverseBins}
	
	rm ${tmpBedReverse}	
	
	#Get return code from last program call
	returnCode=$?

	
	echo -e "\nreturnCode CreateBinsReverse: $returnCode\n\n"
	if [ $returnCode -eq 0 ]
		then
  		echo -e "\nCreateBins finished succesfull. Moving temp files to final.\n\n"
  	  	mv ${tmpReverseBins} ${reverseBins}
    	putFile "${reverseBins}"
    
    
	else
   		echo -e "\nFailed to move CreatebinsReverse results to ${intermediateDir}\n\n"
    	exit -1
	fi
fi














