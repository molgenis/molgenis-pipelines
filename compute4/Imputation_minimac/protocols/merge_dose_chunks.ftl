#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,sampleChunk


#/target/gpfs2/gcc/groups/gonl/projects/imputationBenchmarking/imputationResult/lifelines_MinimacV2_refGoNLv4//chunk1-chr1_sampleChunk1.imputed.plink.dose.gz

STUDY_LENGTH=`expr length "${imputationResultDir}/chunk"`
STUDY_LENGTH=`expr $STUDY_LENGTH + 1`

for temp_chunk in {1..50}
do
	getFile ${imputationResultDir}/chunk$temp_chunk-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz
done



alloutputsexist \
	${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz

TO_RUN=$(echo "cat "; ls -1 ${imputationResultDir}/chunk*-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz | sort -n -k 1.$STUDY_LENGTH | while read CMD; do value=`expr $value + 1`; if [ $value -eq 1 ]; then echo " <( zcat $CMD) "; else echo " <( zcat $CMD | tail -n +2) "; fi; done; echo " | gzip > ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz  ")

echo "dose Merging Script:" 
echo $TO_RUN

echo $TO_RUN > ${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.merge_dose.sh

. ${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.merge_dose.sh

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz ${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1
fi


