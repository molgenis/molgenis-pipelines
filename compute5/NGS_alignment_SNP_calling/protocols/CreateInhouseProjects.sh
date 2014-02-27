# =====================================================
#
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# $seqType
# ${projectRawArraytmpDataDir}
# ${projectRawtmpDataDir}
# ${projectJobsDir}
# ${projectLogsDir}
# ${intermediateDir}
# ${projectResultsDir}
# ${projectQcDir}
# =====================================================
#

#string seqType
#string projectRawArraytmpDataDir
#string projectRawtmpDataDir
#string projectJobsDir
#string projectLogsDir
#string intermediateDir
#string projectResultsDir
#string projectQcDir

#string mainParameters
#string chrParameters 
#string worksheet 
#string outputdir

#list internalSampleID
#string project
#string scriptDir

#MOLGENIS walltime=00:10:00
#FOREACH project

#
# Change permissions.
#
umask 0007

module load jdk
module list

#
# Create project dirs.
#
mkdir -p ${projectRawArraytmpDataDir}
mkdir -p ${projectRawtmpDataDir}
mkdir -p ${projectJobsDir}
mkdir -p ${projectLogsDir}
mkdir -p ${intermediateDir}
mkdir -p ${projectResultsDir}
mkdir -p ${projectQcDir}

ROCKETPOINT=`pwd`
cd ${projectRawtmpDataDir}

#
# Create symlinks to the raw data required to analyse this project
#
# For each sequence file (could be multiple per sample):
#
#<#list internalSampleID as sample>

((n_elements=${internalSampleID[@]}, max_index=n_elements -1))
for ((samplenumber = 0; samplenumber <= max_index; samplenumber++))
	if [[ ${seqType[samplenumber]} == "SR" ]]
	then
        if [[ ${barcode[samplenumber]} == "None" ]]
        then
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedFastqFilenameSR[samplenumber]} ${projectRawtmpDataDir}/${compressedFastqFilenameNoBarcodeSR[samplenumber]}
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${fastqChecksumFilenameSR[samplenumber]} ${projectRawtmpDataDir}/${fastqChecksumFilenameNoBarcodeSR[samplenumber]}

            # Also add a symlink for the alignment step: 
			ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedFastqFilenameSR[samplenumber]} ${projectRawtmpDataDir}/${compressedFastqFilenameNoBarcodePE1[samplenumber]}
        else
  			ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedDemultiplexedSampleFastqFilenameSR[samplenumber]} ${projectRawtmpDataDir}/
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${demultiplexedSampleFastqChecksumFilenameSR[samplenumber]} ${projectRawtmpDataDir}/

            # Also add a symlink for the alignment step:
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedFastqFilenameSR[samplenumber]} ${projectRawtmpDataDir}/${compressedFastqFilenameNoBarcodePE1[samplenumber]}
        fi

	elif [[ ${seqType[samplenumber]} == "PE" ]]
    	if [[ ${barcode[samplenumber]} == "None" ]]
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedFastqFilenamePE1[samplenumber]} ${projectRawtmpDataDir}/${compressedFastqFilenameNoBarcodePE1[samplenumber]}
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedFastqFilenamePE2[samplenumber]} ${projectRawtmpDataDir}/${compressedFastqFilenameNoBarcodePE2[samplenumber]}
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${fastqChecksumFilenamePE1[samplenumber]} ${projectRawtmpDataDir}/${fastqChecksumFilenameNoBarcodePE1[samplenumber]}
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${fastqChecksumFilenamePE2[samplenumber]} ${projectRawtmpDataDir}/${fastqChecksumFilenameNoBarcodePE2[samplenumber]}
        else
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedDemultiplexedSampleFastqFilenamePE1[samplenumber]} ${projectRawtmpDataDir}/
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${compressedDemultiplexedSampleFastqFilenamePE2[samplenumber]} ${projectRawtmpDataDir}/
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${demultiplexedSampleFastqChecksumFilenamePE1[samplenumber]} ${projectRawtmpDataDir}/
            ln -s ../../../../../rawdata/ngs/${runPrefix[samplenumber]}/${demultiplexedSampleFastqChecksumFilenamePE2[samplenumber]} ${projectRawtmpDataDir}/
        fi
    fi

done


cd $ROCKETPOINT

#
# TODO: array for each sample:
#

#
# Create subset of samples for this project.
#
<#--<#assign unfolded = unfoldParametersCSV(parameters) />
#<#list unfolded as sampleSequenceDetails>
#echo ${sampleSequenceDetails} >> ${projectJobsDir}/${project}.csv
#</#list>-->
${scriptDir}/extract_samples_from_GAF_list.pl --i ${worksheet} --o ${projectJobsDir}/${project}.csv --c project --q ${project}

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#

cd ..

sh molgenis_compute.sh -p ${mainParameters} \
-p {chrParameters} -p ${worksheet} -rundir ${outputdir}
-w workflow.csv -b pbs -g -weave -runid test01

