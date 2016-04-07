#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00

#Parameter mapping
#string tmpName
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string tmpDataDir
#string logsDir
#string project
#string projectRawTmpDataDir

sleep 10

checkIlluminaEncoding() {
barcodeFqGz=$1
echo ${barcodeFqGz}

lines=(`zcat ${barcodeFqGz} | head -8000 | tail -192 | awk 'NR % 4 == 0'`)
count=1
nodecision=0
numberoflines=0
for line in  ${lines[@]}
do
	numberoflines=$(( numberoflines+1 ))
	#check for illumina encoding 1.5
	if [[ "$line" =~ [P-Z] ]] || [[ "$line" =~ [a-g] ]]
		then
        	encoding="1.5"
	        if [[ ${count} -eq 1 ]]
        	then
            	lastEncoding=${encoding}
            	count=$(( count+1 ))
        	fi

        	if ! [ "${encoding}" == "${lastEncoding}" ]
        	then
	            	echo "error, encoding not possible"
			echo "${encoding} is not matching last encoding (${lastEncoding}"
            		echo "LINE: " $line
			exit 1
        	fi
        	lastEncoding=${encoding}

	#check for illumina encoding 1.8/1.9
	elif [[ "$line" =~ [0-9] ]] || [[ "$line" =~ [\<=\>?] ]]
     	then
        	encoding="1.9"
	        if [[ ${count} -eq 1 ]]
        	then
        		lastEncoding=${encoding}
	        	count=$(( count+1 ))
        	fi
        	if ! [ "${encoding}" == "${lastEncoding}" ]
        	then
                	echo "error, encoding not possible"
			echo "${encoding} is not matching last encoding (${lastEncoding}"
			echo "LINE: " $line
	                exit 1
                fi
              	lastEncoding="${encoding}"
	elif [[ "$line" =~ @ ]] || [[ "$line" =~ [A-J] ]]
        	then
                nodecision=$(( nodecision+1 ))
	else
		echo "The encoding is not matching to anything, check FastQ documentation (count=$count)"
	fi
done
if [ "${nodecision}" == "${numberoflines}" ]
then
	echo "Within all the lines, no decision was made about the encoding, all the encoding is between A and J. This is then probably an 1.9 encoding sample, so 1.9 is set as encoding"
	encoding="1.9"
fi

if [ "${encoding}" == "1.9"  ]
then
	echo "encoding is Illumina 1.8 - Sanger / Illumina 1.9"
else
	#make fasta out of the fq.gz file
        gzip -d -c ${barcodeFqGz} > ${barcodeFqGz}.fq
	mkdir -p ${projectRawTmpDataDir}/IlluminaEncoding1.5
        mv ${barcodeFqGz} ${projectRawTmpDataDir}/IlluminaEncoding1.5/
	echo "start encoding for ${barcodeFqGz}.fq"
        #convert Phreds+64 to Phred+33 (Illumna 1.5 TO Illumina / Sanger 1.9)
        sed -e '4~4y/@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghi/!"#$%&'\''()*+,-.\/0123456789:;<=>?@ABCDEFGHIJ/' ${barcodeFqGz}.fq > ${barcodeFqGz}.fq.encoded
        gzip ${barcodeFqGz}.fq.encoded
        mv ${barcodeFqGz}.fq.encoded.gz ${barcodeFqGz}
fi

}

#check illumina encoding using function checkIlluminaEncoding()

#If paired-end do fastqc for both ends, else only for one
if [ "${seqType}" == "SR" ]
then
        checkIlluminaEncoding ${srBarcodeFqGz}

elif [ "${seqType}" == "PE" ]
then
        checkIlluminaEncoding ${peEnd1BarcodeFqGz}
        checkIlluminaEncoding ${peEnd2BarcodeFqGz}
else
	echo "SeqType unknown"
	exit 1
fi
