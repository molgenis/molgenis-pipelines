#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string stage
#string checkStage
#string fastqcVersion
#string intermediateDir
#string peEnd1BarcodeFastQc
#string peEnd2BarcodeFastQc
#string srBarcodeFastQc

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "fastqcVersion: ${fastqcVersion}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQc: ${peEnd1BarcodeFastQc}"
echo "peEnd2BarcodeFastQc: ${peEnd2BarcodeFastQc}"
echo "srBarcodeFastQc: ${srBarcodeFastQc}"

sleep 10

#If paired-end then copy 2 files, else only 1
if [ ${seqType} == "PE" ]
then
        alloutputsexist \
        "${peEnd1BarcodeFastQc}.zip" \
        "${peEnd2BarcodeFastQc}.zip"
        
	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else
        alloutputsexist \
        "${srBarcodeFastQc}.zip"
        
	getFile ${srBarcodeFqGz}

fi

#Load module
${stage} fastqc/${fastqcVersion}
${checkStage}
makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	# end1 & end2
	fastqc ${peEnd1BarcodeFqGz} \
	${peEnd2BarcodeFqGz} \
	-o ${tmpIntermediateDir}
	
	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${peEnd1BarcodeFastQc}.zip"
        putFile "${peEnd2BarcodeFastQc}.zip"

	#check illumina encoding
	checkEncoding=`grep Encoding ${peEnd2BarcodeFastQc}/fastqc_data.txt`
	returncode=`echo $checkEncoding | grep 1.5`

	if [[ ${returncode} == "" ]]
		then
        	echo 'encoding is not 1.5, no reEncoding is necessary'
        	echo $checkEncoding
	else
        	echo 'encoding is 1.5.. RE-ENCODING!!'
        	#make fasta out of the fq.gz file
        	zcat ${peEnd1BarcodeFqGz} | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ${peEnd1BarcodeFqGz}.fa
        	zcat ${peEnd2BarcodeFqGz} | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ${peEnd2BarcodeFqGz}.fa

	        #convert Phreds+64 to Phred+33 (Illumna 1.5 TO Illumina / Sanger 1.9)
        	sed -e -i '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${peEnd1BarcodeFqGz}.fa
        	sed -e -i '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${peEnd2BarcodeFqGz}.fa
        	gzip -c ${peEnd1BarcodeFqGz}
        	gzip -c ${peEnd2BarcodeFqGz}

	fi

else
	fastqc ${srBarcodeFqGz} \
	-o ${tmpIntermediateDir}

	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${srBarcodeFastQc}.zip"

	#check illumina encoding
        checkEncoding=`grep Encoding ${srBarcodeFqGz}/fastqc_data.txt`
        returncode=`echo $checkEncoding | grep 1.5`

	if [[ ${returncode} == "" ]]
	then
        	echo 'encoding is not 1.5, no reEncoding is necessary'
        	echo $checkEncoding
	else
        	echo 'encoding is 1.5.. RE-ENCODING!!'
        	#make fasta out of the fq.gz file
        	zcat ${srBarcodeFqGz} | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ${srBarcodeFqGz}.fa

        	#convert Phreds+64 to Phred+33 (Illumna 1.5 TO Illumina / Sanger 1.9)
        	sed -e -i '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${srBarcodeFqGz}.fa
        	gzip -c ${srBarcodeFqGz}
	fi
fi

cd ${peEnd2BarcodeFastQc}

checkEncoding=`grep Encoding fastqc_data.txt`

returncode=`echo $checkEncoding | grep 1.5`


if [[ ${returncode} == "" ]]
then
        echo 'encoding is not 1.5, no reEncoding is necessary'
        echo $checkEncoding
else
        echo 'encoding is 1.5.. RE-ENCODING!!'
	#make fasta out of the fq.gz file
	zcat ${peEnd1BarcodeFqGz} | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ${peEnd1BarcodeFqGz}.fa
	zcat ${peEnd2BarcodeFqGz} | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > ${peEnd2BarcodeFqGz}.fa
	
	#convert Phreds+64 to Phred+33 (Illumna 1.5 TO Illumina / Sanger 1.9)
	sed -e -i '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${peEnd1BarcodeFqGz}.fa
	sed -e -i '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${peEnd2BarcodeFqGz}.fa
	gzip -c ${peEnd1BarcodeFqGz}
	gzip -c ${peEnd2BarcodeFqGz}
	
fi
