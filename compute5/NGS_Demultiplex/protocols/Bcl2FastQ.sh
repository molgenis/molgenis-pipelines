#MOLGENIS walltime=12:00:00 nodes=1 ppn=6 mem=12gb
#string bcl2fastqVersion
#string hiseqDir
#string nextseqDir
#string NGSDir
#string nextseqRunDataDir
#string runResultsDir
#string stage
#string checkStage

#
# Setup environment for tools we need.
#
${stage} ${bcl2fastqVersion}
${stage} ngs-utils

${checkStage}

#
# Initialize script specific vars.
#

makeTmpDir ${runResultsDir}
tmpRunResultsDir=${MC_tmpFile}

#
# Create sample sheet in Illumina format based on our GAF sample sheets.
#

CreateIlluminaSampleSheet.pl \
#-i ${McWorksheet} \
#-o ${tmpIntermediateDir}/Illumina_R${run}.csv \
#-r ${run}

#
# Configure BCL to FastQ conversion using Illumina tool possibly including demultiplexing with 1 mismatche.
#

#INPUTFOLDER="/groups/umcg-gaf/tmp05/rawdata/nextseq/150707_NB501043_0002_AHGNTVBGXX"
#OUTPUTFOLDER="/groups/umcg-gaf/tmp05/rawdata/ngs/150707_NB501043_0002_AHGNTVBGXX"
##SAMPLESHEET="/groups/umcg-gaf/tmp05/generatedscripts/demultiplexing/SampleSheet.csv"
#SAMPLESHEET="/groups/umcg-gaf/tmp05/rawdata/nextseq/150707_NB501043_0002_AHGNTVBGXX/SampleSheet.csv"

#
#
bcl2fastq \
--runfolder-dir ${nextseqRunDataDir} \
--output-dir ${tmpRunResultsDir} \
--sample-sheet ${tmpIntermediateDir}/Illumina_R${run}.csv 

mv ${tmpRunResultsDir}/* ${runResultsDir}
