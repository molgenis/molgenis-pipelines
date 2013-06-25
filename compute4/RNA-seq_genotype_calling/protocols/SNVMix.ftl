#MOLGENIS walltime=5:00:00 nodes=1 cores=1 mem=4

sortedBam="${sortedBam}"
SNVMix="${SNVMix}"
samtools="${samtools}"
snpList="${snpList}"
faFile="${faFile}"
echo -e "samtools=${samtools}\nSNVMix=${SNVMix}\nsnpList=${snpList}\nfaFile=${faFile}\nsortedBam=${sortedBam}"

<#noparse>
mpileupFile=${sortedBam//bam/mpileup}
snvmixOut=${mpileupFile}.snvmix

echo "Writing mpileup output to $mpileupFile"

${samtools} mpileup \
-A -B -Q 0 -s -d10000000 \
-l ${snpList} \
-f ${faFile} \
${sortedBam} \
> $mpileupFile

echo "Writing SNVMix output to $snvmixOut"

${SNVMix} \
-i $mpileupFile \
-o $snvmixOut

gzip ${outPrefix}.mpileup

</#noparse>