#MOLGENIS walltime=12:00:00 nodes=1 ppn=1 mem=1gb
#string runResultsDir
#string bcl2fastqDir
#list internalSampleID
#list seqType
#list barcode
#list barcodeType
#list lane
#list sequencingStartDate
#list sequencer
#list flowcell
#list run

n_elements=${internalSampleID[@]}
max_index=${#internalSampleID[@]}-1
for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
do
	if [[ ${seqType[samplenumber]} == "SR" ]]
	then
  		if [[ ${barcode[samplenumber]} == "None" || ${barcodeType[samplenumber]} == "GAF" ]]
		then
			#
                        # Process lane FastQ files for lanes without barcodes or with GAF barcodes.
                        #

			cd ${bcl2fastqDir}
			md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}.fq.gz
			cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}.fq.gz
			cd  ${runResultsDir}
			md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}.fq.gz.md5

  		else

			cd ${bcl2fastqDir}
			md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz >  ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5
			cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz
			cd ${runResultsDir}
			md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5

		fi
	elif [[ ${seqType[samplenumber]} == "PE" ]]
	then
		if [[ ${barcode[samplenumber]} == "None" ]]
    		then

		cd ${bcl2fastqDir}
                md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_1.fq.gz.md5
		md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz > ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_2.fq.gz.md5
		cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_1.fq.gz
		cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_2.fq.gz
		cd  ${runResultsDir}
                md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_1.fq.gz.md5
		md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_2.fq.gz.md5

		else

		cd ${bcl2fastqDir}
                md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
                md5sum Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz > ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5
                cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz
                cp ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz ${runResultsDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz
                cd  ${runResultsDir}
                md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
                md5sum -c ${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5

    		fi
 	else
		#
        	# Found unknown barcode type!
        	#
		echo "FATAL: unknown barcode type found for ${filenamePrefix}"
		exit 1
	fi
done
