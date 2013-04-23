#
# =============================================================================
# Illumina to GAF FastQs:
#  * Copy FastQ files to run folder.
#  * Rename FastQ files using GAF conventions.
#  * Calculate md5sums.
# =============================================================================
#

#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=01:00:00 nodes=1 cores=1 mem=1
#FOREACH sequencingStartDate, sequencer, run, flowcell, lane

#
# Bash sanity.
#
set -e
set -u

#
# Change permissions.
#
umask ${umask}

#
# Initialize script specific vars.
#
RESULTDIR=<#if runResultsDir?is_enumerable>${runResultsDir[0]}<#else>${runResultsDir}</#if>
SCRIPTNAME=${jobname}
FLUXDIR=<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>_in_flux/
<#assign fluxDir>${r"${FLUXDIR}"}</#assign>

#
# Should I stay or should I go?
#
if [ -f "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished" ]
then
    # Skip this job script.
	echo "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

<#if seqType == "SR">
#
# For Single Read data (seqType == SR).
#
	
	<#if barcode[0] == "None" || barcodeType[0] == "GAF">
	#
	# Process lane FastQ files for lanes without barcodes or with GAF barcodes.
	#
	getfile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedFastqFilenameSR}/' ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedFastqFilenameSR}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenameSR}${md5sumExtension}
	
	<#elseif barcodeType[0] == "RPI" || barcodeType[0] == "MON">
	#
	# Process sample FastQ files for lanes with RPI or MON barcodes.
	#
	<#list compressedDemultiplexedSampleFastqFilenameSR as file>
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${file}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${file}/' ${fluxDir}/${file}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz ${fluxDir}/${file}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${file}${md5sumExtension}
		
	</#list>
	#
	# Same for the FastQ file with "discarded" reads that could not be assigned to a sample.
	#
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenameSR}/' ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenameSR}${md5sumExtension}
	
	<#else>
	#
	# Found unknown barcode type!
	#
	echo "FATAL: unknown barcode type found for ${filenamePrefix}"
	exit 1
	</#if>
	
<#elseif seqType == "PE">
#
# For Paired End data (seqType == PE).
#	
	<#if barcode[0] == "None" || barcodeType[0] == "GAF">
	#
	# Process lane FastQ files for lanes without barcodes or with GAF barcodes.
	#
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedFastqFilenamePE1}/' ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedFastqFilenamePE1}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenamePE1}${md5sumExtension}
	
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedFastqFilenamePE2}/' ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_NoIndex_L00${lane}_R2_001.fastq.gz ${fluxDir}/${compressedFastqFilenamePE2}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedFastqFilenamePE2}${md5sumExtension}
	
	<#elseif barcodeType[0] == "RPI" || barcodeType[0] == "MON">
	#
	# Process sample FastQ files for lanes with RPI or MON barcodes.
	#
	<#list compressedDemultiplexedSampleFastqFilenamePE1 as file>
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${file}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${file}/' ${fluxDir}/${file}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R1_001.fastq.gz ${fluxDir}/${file}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${file}${md5sumExtension}
		
	</#list>
	<#list compressedDemultiplexedSampleFastqFilenamePE2 as file>
	getFile ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${file}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${file}/' ${fluxDir}/${file}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Project_${flowcell}/Sample_lane${lane}/lane${lane}_${barcode[file_index]}_L00${lane}_R2_001.fastq.gz ${fluxDir}/${file}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${file}${md5sumExtension}
		
	</#list>
	#
	# Same for the FastQ files with "discarded" reads that could not be assigned to a sample.
	#
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenamePE1}/' ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R1_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE1}${md5sumExtension}
	
	getFile ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz
	md5sum ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz > ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
	perl -pi -e 's/\s[^\s]+/ ${compressedDemultiplexedDiscardedFastqFilenamePE2}/' ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
	cp -v ${bcl2fastqDir}/Undetermined_indices/Sample_lane${lane}/lane${lane}_Undetermined_L00${lane}_R2_001.fastq.gz ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}
	cd ${fluxDir}
	md5sum -c ${fluxDir}/${compressedDemultiplexedDiscardedFastqFilenamePE2}${md5sumExtension}
    
	<#else>
	#
	# Found unknown barcode type!
	#
	echo "FATAL: unknown barcode type found for ${filenamePrefix}"
	exit 1
	
	</#if>
	
</#if>

#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${fluxDir}/* <#noparse>${RESULTDIR}/</#noparse>
rmdir ${fluxDir}
sync
touch <#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished
sync
