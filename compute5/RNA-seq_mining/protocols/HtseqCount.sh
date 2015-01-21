#MOLGENIS nodes=1 ppn=1 mem=6gb walltime=23:59:00

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string fastqcVersion
#string WORKDIR
#string projectDir

#string markDuplicatesBam
#string markDuplicatesBai
#string genomeEnsembleAnnotationFile

#string samtoolsVersion
#string anacondaVersion
#string htseqCountDir
#string htseqCountCounts

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${htseqCountCounts}

getFile ${markDuplicatesBam}
getFile ${markDuplicatesBai}

${stage} anaconda/${anacondaVersion}
${stage} samtools/${samtoolsVersion}
${checkStage}

set -x
set -e

mkdir -p ${htseqCountDir}

samtools view -h ${markDuplicatesBam} | htseq-count -m union -s no -t exon -i gene_id - ${genomeEnsembleAnnotationFile} > ${htseqCountCounts}

putFile ${htseqCountCounts}

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
