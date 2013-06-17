#MOLGENIS walltime=15:00:00 nodes=1 cores=1 mem=4
#TARGETS

getFile ${adapters}
getFile ${leftbarcodefqgz}
getFile ${rightbarcodefqgz}


#Trim reads for adapters using Illumina TruSeq adapter file
${fastqmcf} \
-s 1.5 \
-t 0.05 \
${adapters} \
${leftbarcodefqgz} \
${rightbarcodefqgz} \
-o ${lefttrimmedbarcodefq} \
-o ${righttrimmedbarcodefq}

#Gzip *.fq files
gzip ${lefttrimmedbarcodefq}
gzip ${righttrimmedbarcodefq}


putFile ${lefttrimmedbarcodefqgz}
putFile ${righttrimmedbarcodefqgz}