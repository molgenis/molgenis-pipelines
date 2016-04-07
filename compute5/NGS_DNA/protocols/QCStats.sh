#MOLGENIS ppn=1 mem=8gb walltime=06:00:00

#Parameter mapping
#string tmpName
#string intermediateDir
#string qcMetrics
#string alignmentMetrics
#string sampleConcordanceFile
#string hsMetrics
#string insertSizeMetrics
#string flagstatMetrics
#string externalSampleID
#string ngsUtilsVersion
#string pythonVersion
#string project


#Load module
module load ${pythonVersion}
module load ${ngsUtilsVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

if [ -f ${qcMetrics} ]
then
	rm ${qcMetrics}
fi 

printf "Sample:\t${externalSampleID}\n" > ${qcMetrics}

#If paired-end do fastqc for both ends, else only for one
python $EBROOTNGSMINUTILS/pull_DNA_Seq_Stats.py \
-a ${alignmentMetrics} \
-c ${sampleConcordanceFile} \
-s ${hsMetrics} \
-i ${insertSizeMetrics} \
-f ${flagstatMetrics} \
>> ${qcMetrics}

