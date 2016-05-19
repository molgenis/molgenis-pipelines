#MOLGENIS walltime=12:00:00 nodes=1 ppn=1 mem=1gb
#string runResultsDir
#string intermediateDir
#list internalSampleID
#string seqType
#list barcode
#list barcodeType
#string lane
#string sequencingStartDate
#string sequencer
#string flowcell
#string run
#string filenamePrefix

OLDDIR=`pwd`

n_elements=${internalSampleID[@]}
max_index=${#internalSampleID[@]}-1
for ((sampleNumber = 0; sampleNumber <= max_index; sampleNumber++))
do
	if [ "${seqType}" == "SR" ]
	then
  		if [[ ${barcode[sampleNumber]} == "None" || ${barcodeType[sampleNumber]} == "GAF" ]]
		then
                        # Process lane FastQ files for lane without barcodes or with GAF barcodes.
			cd ${intermediateDir}

			md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz.md5

			cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz

			cd  ${runResultsDir}
			VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz
			perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

			md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}.fq.gz
		###CORRECT BARCODES
		elif [[ ${barcodeType[sampleNumber]} == "RPI" || ${barcodeType[sampleNumber]} == "BIO" || ${barcodeType[sampleNumber]} == "MON" || ${barcodeType[sampleNumber]} == "AGI" || ${barcodeType[sampleNumber]} == "LEX" || ${barcodeType[sampleNumber]} == "NEX" || ${barcodeType[sampleNumber]} == "AG8" || ${barcodeType[sampleNumber]} == "sRP" ]]
		then
			cd ${intermediateDir}
			md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz > ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}.fq.gz.md5

			cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}.fq.gz

			cd ${runResultsDir}
			VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}.fq.gz
                        perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

			md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}.fq.gz.md5

else
                #
                # Found unknown barcode type!
                #
                echo "FATAL: unknown barcode type found for ${filenamePrefix}"
                exit 1
	        fi

	elif [ "${seqType}" == "PE" ]
	then
		if [[ ${barcode[sampleNumber]} == "None" ]]
    		then
		cd ${intermediateDir}
		md5sum lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz.md5
		md5sum lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz.md5

		cp lane${lane}_None_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz
		cp lane${lane}_None_S[0-9]*_L00${lane}_R2_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz

		cd  ${runResultsDir}

		VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz
		VAR2=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz

		perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
                perl -pi -e "s|lane${lane}_None_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5

		md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_1.fq.gz.md5
		md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_2.fq.gz.md5

		###CORRECT BARCODES
		elif [[ ${barcodeType[sampleNumber]} == "RPI" || ${barcodeType[sampleNumber]} == "BIO" || ${barcodeType[sampleNumber]} == "MON" || ${barcodeType[sampleNumber]} == "AGI" || ${barcodeType[sampleNumber]} == "LEX" || ${barcodeType[sampleNumber]} == "NEX" || ${barcodeType[sampleNumber]} == "AG8" || ${barcodeType[sampleNumber]} == "sRP" ]]
		then
		cd ${intermediateDir}
		md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_1.fq.gz.md5
		md5sum lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5

		cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_1.fq.gz
		cp lane${lane}_${barcode[sampleNumber]}_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_2.fq.gz

                cd  ${runResultsDir}

                VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_1.fq.gz
                VAR2=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_2.fq.gz

                perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
                perl -pi -e "s|lane${lane}_${barcode[sampleNumber]}_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5

                md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_1.fq.gz.md5
                md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode[sampleNumber]}_2.fq.gz.md5


    		fi
 	else
		#
        	# Found unknown barcode type!
        	#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1
	fi
done

#discarded reads that could not be assigned to a sample.

if [ "${barcode[0]}" != "None" ]
then
	if [ "${seqType}" == "SR" ]
	then
		cd ${intermediateDir}
        	md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz.md5

                cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz

                cd  ${runResultsDir}

                VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz

                perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5

                md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED.fq.gz.md5
	else
        #DISCARDED READS
		cd ${intermediateDir}
        	md5sum Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz.md5
        	md5sum Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5

	  	cp Undetermined_S[0-9]*_L00${lane}_R1_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz
                cp Undetermined_S[0-9]*_L00${lane}_R2_001.fastq.gz  ${runResultsDir}/${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz

	        cd  ${runResultsDir}

	        VAR1=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz
                VAR2=${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz

                perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R1_001.fastq.gz|$VAR1|" $VAR1.md5
                perl -pi -e "s|Undetermined_S[0-9]+_L00${lane}_R2_001.fastq.gz|$VAR2|" $VAR2.md5

                md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_1.fq.gz.md5
                md5sum -c ${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_DISCARDED_2.fq.gz.md5
	fi
else
		echo "There can't be discarded reads because the Barcode is set to None"
fi

cd $OLDDIR
