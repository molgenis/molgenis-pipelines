#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr

STUDY_LENGTH=`expr length "${imputationResultDir}/chr${chr}_sampleChunk"`
STUDY_LENGTH=`expr $STUDY_LENGTH + 1`

#chr10_sampleChunk11.imputed.ped

for sampleChunk in {1..50}
do
	getFile ${imputationResultDir}/chr10_sampleChunk$sampleChunk.imputed.ped
	getFile ${imputationResultDir}/chr10_sampleChunk$sampleChunk.imputed.map
done


alloutputsexist \
	${imputationResultDir}/chr${chr}.imputed.ped \
	${imputationResultDir}/chr${chr}.imputed.map

TO_RUN=$(echo "cat ";ls -1 ${imputationResultDir}/chr${chr}_sampleChunk*.imputed.ped | sort -n -k 1.$STUDY_LENGTH | while read CMD; do echo " $CMD "; done; echo " > ${imputationResultDir}/~chr${chr}.imputed.ped")
echo "PED Merging script: "
echo $TO_RUN

echo "script saved at: ${imputationResultDir}/chr${chr}.imputed.merge_ped.sh"

echo $TO_RUN > ${imputationResultDir}/chr${chr}.imputed.merge_ped.sh

. ${imputationResultDir}/chr${chr}.imputed.merge_ped.sh

returnCode=$?

if [ $returnCode -eq 0 ]
then
	mv ${imputationResultDir}/~chr${chr}.imputed.ped ${imputationResultDir}/chr${chr}.imputed.ped

	putFile ${imputationResultDir}/chr${chr}.imputed.ped

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1
fi

cp ${imputationResultDir}/chr${chr}_sampleChunk1.imputed.map ${imputationResultDir}/~chr${chr}.imputed.map

returnCode=$?

if [ $returnCode -eq 0 ]
then
        mv ${imputationResultDir}/~chr${chr}.imputed.map ${imputationResultDir}/chr${chr}.imputed.map

        putFile ${imputationResultDir}/chr${chr}.imputed.map
        
else

        echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
        #Return non zero return code
        exit 1
fi

