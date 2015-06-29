#MOLGENIS walltime=24:00:00 nodes=1 ppn=8 mem=10gb

#Parameter mapping
#string peEnd1BarcodeTrimmedFqGz
#string peEnd2BarcodeTrimmedFqGz
#string intermediateDir
#string externalSampleID
#string bowtieIndex
#string seqType
#string jdkVersion
#string sequencer 
#string library
#string flowcell
#string run
#string barcode
#string lane
#string picardVersion
#string bowtieVersion


#Echo parameter values
fastq1="${peEnd1BarcodeTrimmedFqGz}"
fastq2="${peEnd2BarcodeTrimmedFqGz}"
outputFolder="${intermediateDir}"
prefix="${externalSampleID}"
bowtieindex="${bowtieIndex}"
seqType="${seqType}"


#load modules JDK,Bowtie,PICARDTools
module load jdk/${jdkVersion}
module load bowtie2/${bowtieVersion}
module load picard-tools/${picardVersion}
module list

hostname

echo -e "fastq1=${fastq1}\nfastq2=${fastq2}\noutputFolder=${outputFolder}\nprefix=${prefix}\nSTARindex=${bowtieIndex}"

mkdir -p ${outputFolder}

inputs ${fastq1}

seq=`zcat ${fastq1} | head -2 | tail -1`
echo "seq used to determine read length: ${seq}"
readLength="${#seq}"

if [ $readLength -ge 90 ]; then
	numMism=4
elif [ $readLength -ge 60 ]; then
	numMism=3
else
	numMism=2
fi

echo "readLength=$readLength"


#if [ ${#fastq2} -eq 0 ]; 
if [ ${seqType} == "SR" ]
then

	bowtie2 -p 7 \
	-x ${bowtieIndex} \
	-U ${fastq1} \
	-S ${TMPDIR}/${prefix}___tmp___.Aligned.out.sam >> ${outputFolder}/${prefix}.Log.out 2>&1

	bowtieReturnCode=$?

elif [ ${seqType} == "PE" ]
then
	inputs ${fastq2}

	echo "Mapping paired-end reads"
	let numMism=$numMism*2
	echo "Allowing $numMism mismatches"

	bowtie2 -p 7\
        -x ${bowtieIndex} \     
        -1 ${fastq1} \
        -2 ${fastq2} \
	-S ${TMPDIR}/${prefix}___tmp___.Aligned.out.sam	>> ${outputFolder}/${prefix}.Log.out 2>&1
	
	bowtieReturnCode=$?
else 
	echo "Seqtype unknown"
	exit 1
	
fi

#format logfile

perl -nle 'print $2,"|\t",$1 while (m%^[ ]*([.0-9\%]+\s\(.+\)|[.0-9\%]+).(.+)%g);' ${outputFolder}/${prefix}.Log.out > ${outputFolder}/${prefix}.Log.final.out


echo "Bowtie return code: ${bowtieReturnCode}"

if [ $bowtieReturnCode -eq 0 ]
then

	for tempFile in ${TMPDIR}/${prefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


# Add readgroup and sort
# READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"
# RGID=group1 RGLB= lib1 RGPL=illumina RGPU=unit1 RGSM=sample1 

java -Xmx6g -jar $PICARD_HOME/AddOrReplaceReadGroups.jar \
INPUT=${TMPDIR}/${prefix}.Aligned.out.sam \
OUTPUT=${outputFolder}/${prefix}___tmp___.Aligned.out.sorted.bam \
SORT_ORDER=coordinate \
RGID=${lane} \
RGLB=${library} \
RGPL="illumina" \
RGPU=${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
RGSM=${externalSampleID} \
CREATE_INDEX=true \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR=${TMPDIR}

returnCode=$?

echo "Picard return code: ${returnCode}"

if [ $returnCode -eq 0 ]
then

	for tempFile in ${outputFolder}/${prefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done

	cd $outputFolder
	md5sum $prefix.Aligned.out.sorted.bam > $finalFile.md5
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi
