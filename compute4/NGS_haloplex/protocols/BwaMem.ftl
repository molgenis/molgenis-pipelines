#MOLGENIS walltime=23:59:00 nodes=1 cores=4 mem=6
#TARGETS

getFile ${indexfile}
getFile ${lefttrimmedbarcodefqgz}
getFile ${righttrimmedbarcodefqgz}

${bwadir} mem \
-t ${bwamemcores} \
-R '@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}' \
${indexfile} \
${lefttrimmedbarcodefqgz} \
${righttrimmedbarcodefqgz} \
> ${samfile}

putFile ${samfile}