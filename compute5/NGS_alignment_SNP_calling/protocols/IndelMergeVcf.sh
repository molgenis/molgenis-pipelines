#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string pindelVcfDir
#string intermediateDir
#string project
#string projectIndelsMerged

#Load Bcftools module
${stage} bcftools/0.2.0

#Load Tabix module
${stage} tabix/0.2.6
${checkStage}

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "pindelVcfDir: ${pindelVcfDir}"

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#prepare the created vcf's for bcftools: bgzip + tabix to set the correct indexes and make correct format

cd ${pindelVcfDir}
echo "selected the following vcf's:"
for i in $(ls *.vcf);
do \
	bgzip -c $i > ${tmpIntermediateDir}$i.gz 
	tabix -p vcf ${tmpIntermediateDir}$i.gz
	echo ${tmpIntermediateDir}$i; \
done 

vcfTmpDir="${tmpIntermediateDir}vcfTmpDir"

mkdir ${vcfTmpDir}
cp ${tmpIntermediateDir}*.gz* ${vcfTmpDir}
cp ${projectIndelsMerged}.gz* ${vcfTmpDir}

cd ${vcfTmpDir}
#merging all the vcf.gz that were created per sample into one big vcf
echo "running bcftools:"
bcftools merge *.vcf.gz --output-type v > ${tmpIntermediateDir}${project}.indels.calls.mergedAllVcf.vcf

echo "written ${project}.indels.calls.mergedAllVcf.vcf TO ${tmpIntermediateDir}"

mv ${tmpIntermediateDir}${project}.indels.calls.mergedAllVcf.vcf ${intermediateDir}${project}.indels.calls.mergedAllVcf.vcf
