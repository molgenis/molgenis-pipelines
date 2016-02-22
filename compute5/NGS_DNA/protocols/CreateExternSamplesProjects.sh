#MOLGENIS walltime=01:59:00 mem=4gb

#list seqType
#string projectRawArrayTmpDataDir
#string projectRawTmpDataDir
#string projectJobsDir
#string projectLogsDir
#string intermediateDir
#string projectResultsDir
#string batchIDList
#string projectQcDir
#string capturedBed
#string environment_parameters

#list sequencingStartDate
#list sequencer
#list run
#list flowcell
#list externalFastQ

#string mainParameters
#string worksheet 
#string outputdir
#string workflowpath

#list internalSampleID
#string project
#string ngsversion
#list barcode
#list lane

umask 0007
module load Molgenis-Compute/${computeVersion}

module list
#
# Create project dirs.
#
mkdir -p ${projectRawArrayTmpDataDir}
mkdir -p ${projectRawTmpDataDir}
mkdir -p ${projectJobsDir}
mkdir -p ${projectLogsDir}
mkdir -p ${intermediateDir}
mkdir -p ${projectResultsDir}
mkdir -p ${projectQcDir}

ROCKETPOINT=`pwd`

cd ${projectRawTmpDataDir}

#
# Create symlinks to the raw data required to analyse this project
#
# For each sequence file (could be multiple per sample):
#


n_elements=${internalSampleID[@]}
max_index=${#internalSampleID[@]}-1
for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
do
	if [[ ${seqType[samplenumber]} == "SR" ]]
	then
  		if [[ ${barcode[samplenumber]} == "None" ]]
		then
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5
  		else
      			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz
      			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5
		fi
	elif [[ ${seqType[samplenumber]} == "PE" ]]
	then
		if [[ ${barcode[samplenumber]} == "None" ]]
    		then
    			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_1.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_2.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_1.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_2.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5
		else          
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_1.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_2.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_1.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${externalFastQ[samplenumber]}_2.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.md5
    		fi
 	fi
done

cd $ROCKETPOINT

echo "before splitting"
echo `pwd`
module load NGS_DNA/$ngsversion
module load ngs-utils

#
# TODO: array for each sample:
#

#
# Create subset of samples for this project.
#

extract_samples_from_GAF_list.pl --i ${worksheet} --o ${projectJobsDir}/${project}.csv --c project --q ${project}

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#


if [ -f .compute.properties ];
then
     rm ../.compute.properties
fi

echo "before run second rocket"
echo pwd

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh -p ${mainParameters} \
-p environment_parameters \
-p ${batchIDList} \
-p ${projectJobsDir}/${project}.csv \
-rundir ${projectJobsDir} \
-w ${workflowpath} \
-b slurm \
-g -weave \
-runid ${runid} \
-o "ngsversion=${ngsversion}"
