#
# =============================================================================
# Illumina to GAF FastQs:
#  * Copy FastQ files to run folder.
#  * Rename FastQ files using GAF conventions.
#  * Calculate md5sums.
# =============================================================================
#

#
##
### parameters declaration.
##
#

#string umask
#string runResultsDir
#string bcl2fastqDir
#string flowcell
#list lane
#string compressedFastqFilenameSR
#string md5sumExtension
#list compressedDemultiplexedDiscardedFastqFilenameSR
#list compressedDemultiplexedSampleFastqFilenameSR
#list compressedDemultiplexedSampleFastqFilenamePE1
#list compressedDemultiplexedSampleFastqFilenamePE2
#list compressedDemultiplexedDiscardedFastqFilenamePE1
#list compressedDemultiplexedDiscardedFastqFilenamePE2
#list compressedFastqFilenamePE1
#list compressedFastqFilenamePE2
#string filenamePrefix
#string seqType
#list barcode
#string barcodeType

#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=01:00:00 nodes=1 cores=1 mem=1


#
# Change permissions.
#
umask ${umask}

#
# Initialize script specific vars.
#
RESULTDIR=${runResultsDir[0]}
SCRIPTNAME=${taskId}
FLUXDIR=${RESULTDIR}/${SCRIPTNAME}_in_flux/
fluxDir=${FLUXDIR}

#
# Should I stay or should I go?
#
if [ -f "${rundir}/${SCRIPTNAME}.sh.finished" ]
then
    # Skip this job script.
	echo "${rundir}/${SCRIPTNAME}.sh.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

if [[ "$seqType" == "SR" ]]
then
#
# For Single Read data (seqType == SR).
#
	if [[ "$barcode" == "None" || "$barcodeType" == "GAF" ]]
	then
	#
	# Process lane FastQ files for lanes without barcodes or with GAF barcodes.
	#
	getfile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedFastqFilenameSR}/" ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedFastqFilenameSR}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	
	elif [[ "$barcodeType" == "RPI" || "$barcodeType" == "MON" || "$barcodeType" == "AGI" ]]
	then
	#
	# Process sample FastQ files for lanes with RPI or MON barcodes.
	#
	
	((n_elements=${#compressedDemultiplexedSampleFastqFilenameSR[@]}, max_index=n_elements - 1))
	for ((file = 0; file <= max_index; file++))
	do
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedSampleFastqFilenameSR[file]}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedSampleFastqFilenameSR[file]}/" ${fluxDir}/${compressedDemultiplexedSampleFastqFilenameSR[file]}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedSampleFastqFilenameSR[file]}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedSampleFastqFilenameSR[file]}${md5sumExtension}
	done	
	
	#
	# Same for the FastQ file with "discarded" reads that could not be assigned to a sample.
	#
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}/" ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	
	else
	
	#
	# Found unknown barcode type!
	#
	echo "FATAL: unknown barcode type found for ${filenamePrefix}"
	exit 1
	
	fi
	
elif [[ "$seqType" == "PE" ]]	
then

#
# For Paired End data (seqType == PE).
#	
	if [[ "$barcode" == "None" || "$barcodeType" == "GAF" ]]
	then
			
	#
	# Process lane FastQ files for lanes without barcodes or with GAF barcodes.
	#
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedFastqFilenamePE1}/" ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedFastqFilenamePE1}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedFastqFilenamePE2}/" ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz ${fluxDir}/${compressedFastqFilenamePE2}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	
	elif [[ "$barcodeType" == "RPI" || "$barcodeType" == "MON" || "$barcodeType" == "AGI" ]]
	then
	
	#
	# Process sample FastQ files for lanes with RPI or MON barcodes.
	#
	
	((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE1[@]}, max_index=n_elements - 1))
	for ((file = 0; file <= max_index; file++))
	do
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE1[file]}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedSampleFastqFilenamePE1[file]}/" ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE1[file]}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE1[file]}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE1[file]}${md5sumExtension}
	
	done	
		
	((n_elements=${#compressedDemultiplexedSampleFastqFilenamePE2[@]}, max_index=n_elements - 1))
	for ((file = 0; file <= max_index; file++))
	do
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE2[file]}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedSampleFastqFilenamePE2[file]}/" ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE2[file]}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file]}_L00${lane}_R2_001.fastq.gz ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE2[file]}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedSampleFastqFilenamePE2[file]}${md5sumExtension}
		
	done
	
	#
	# Same for the FastQ files with "discarded" reads that could not be assigned to a sample.
	#
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenamePE1}/" ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
	sed -i "s/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenamePE2}/" ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
    
	else
	
	#
	# Found unknown barcode type!
	#
	echo "FATAL: unknown barcode type found for ${filenamePrefix}"
	exit 1
	
	fi
	
fi	


#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${fluxDir}/* ${RESULTDIR}/
rmdir ${fluxDir}
sync

