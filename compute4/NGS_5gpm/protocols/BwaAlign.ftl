
#MOLGENIS walltime=15:00:00 nodes=1 cores=8 mem=6
#TARGETS

module load bwa/${bwaVersion}

getFile ${indexfile}
getFile ${leftbarcodefqgz}
getFile ${rightbarcodefqgz}
alloutputsexist "${bwaout}"

mkdir -p "${intermediatedir}"

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"

bwa mem -M \
-R $READGROUPLINE \
-t ${bwaaligncores} \
${indexfile} \
${leftbarcodefqgz} \
${rightbarcodefqgz} > \
${samfile}


putFile ${samfile}