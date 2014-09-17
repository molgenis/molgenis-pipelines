#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"
 
checkIlluminaEncoding() {
barcodeFqGz=$1
echo ${barcodeFqGz}

Lines=(`zcat ${barcodeFqGz} | head -48 | awk 'NR % 4 == 0'`)
count=1
for line in  ${Lines[*]}
do
	if [[ "$line" =~ [0-9] ]] || [[ "$line" =~ [\<=\>?] ]]
	then
		#check if not contains a character from Illumina 1.5
		if ! [[ "$line" =~ [P-Z] ]] || ! [[ "$line" =~ [a-g] ]]
		then
			encoding="1.9"
			if [[ ${count} -eq 1 ]]
			then
                                lastEncoding=${encoding}
				(( count++ ))
			fi
			if ! [ ${encoding} == ${lastEncoding} ]
			then
				echo "error, encoding not possible"
                        	exit 1
			fi 
			lastEncoding=${encoding}
		else
			echo "error, encoding not possible"
			exit 1		
		fi
	else
		if [[ "$line" =~ [P-Z] ]] || [[ "$line" =~ [a-g] ]]
		then
			encoding="1.5"
			if [[ ${count} -eq 1 ]]
			then
                                lastEncoding=${encoding}
				(( count++ ))
                        fi

			if ! [ ${encoding} == ${lastEncoding} ]
                        then
                                echo "error, encoding not possible"
                                exit 1
                        fi
			lastEncoding=${encoding}
		else
			echo "don't know which encoding, check FastQ documentation"
			exit 1
		fi
	fi
done
if [ ${encoding} == "1.9"  ]
then
	echo "encoding is Illumina 1.8 - Sanger / Illumina 1.9"
else
	#make fasta out of the fq.gz file
        gzip -d -c ${barcodeFqGz} > ${barcodeFqGz}.fq
        #convert Phreds+64 to Phred+33 (Illumna 1.5 TO Illumina / Sanger 1.9)
        sed -e '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${barcodeFqGz}.fq > ${barcodeFqGz}.fq.encoded
        gzip ${barcodeFqGz}.fq.encoded
        mv ${barcodeFqGz}.fq.encoded.gz ${barcodeFqGz}
fi		

}

#check illumina encoding using function checkIlluminaEncoding()

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "SR" ]
then
        checkIlluminaEncoding ${srBarcodeFqGz}

elif [ $seqType == "PE" ]
then
        checkIlluminaEncoding ${peEnd1BarcodeFqGz}
        checkIlluminaEncoding ${peEnd2BarcodeFqGz}
else
	echo "SeqType unknown"
	exit 1
fi
