#MOLGENIS walltime=01:59:00 mem=4gb
#string tmpName
#list seqType
#string project
#string projectRawArrayTmpDataDir
#string projectRawTmpDataDir
#string projectJobsDir
#string projectLogsDir
#string intermediateDir
#string projectResultsDir
#string batchIDList
#string projectQcDir
#string capturedBed
#string computeVersion
#string group

#list sequencingStartDate
#list sequencer
#list run
#list flowcell
#list barcode
#list lane
#list internalSampleID

#string mainParameters
#string worksheet 
#string outputdir
#string workflowpath
#string environment_parameters
#string ngsversion
#string ngsUtilsVersion

#string project
#string logsDir

umask 0007

module list
module load Molgenis-Compute/${computeVersion}
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

if [ ! -f ${ROCKETPOINT}/CopyPrmTmpData_0.sh.finished ]
then
	echo "${ROCKETPOINT}/CopyPrmTmpData_0.sh is not finished!!"
	exit 1
fi

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
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5
  		else
      			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz
      			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}.fq.gz.md5
		fi
	elif [[ ${seqType[samplenumber]} == "PE" ]]
	then
		if [[ ${barcode[samplenumber]} == "None" ]]
    		then
    			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_1.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_2.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz
			ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_1.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_2.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5
		else          
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_1.fq.gz.md5
        		ln -sf ../../../../../rawdata/ngs/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.gz.md5 ${projectRawTmpDataDir}/${sequencingStartDate[samplenumber]}_${sequencer[samplenumber]}_${run[samplenumber]}_${flowcell[samplenumber]}_L${lane[samplenumber]}_${barcode[samplenumber]}_2.fq.md5
    		fi
 	fi
done

cd $ROCKETPOINT

echo "before splitting"
echo `pwd`
module load ${ngsUtilsVersion}
module load ${ngsversion}
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
-p ${batchIDList} -p ${projectJobsDir}/${project}.csv -p ${environment_parameters} -p ${group} -rundir ${projectJobsDir} \
--header ${EBROOTMOLGENISMINCOMPUTE}/templates/slurm/header_gaf.ftl \
--submit ${EBROOTMOLGENISMINCOMPUTE}/templates/slurm/submit_gaf.ftl \
-w ${workflowpath} \
-b slurm \
-g -weave \
-runid ${runid} \
-o "ngsversion=${ngsversion}"
