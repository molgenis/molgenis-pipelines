#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,sampleChunk

STUDY_LENGTH=`expr length "${imputationResultDir}/chunk"`
STUDY_LENGTH=`expr $STUDY_LENGTH + 1`

for temp_chunk in {1..50}
do
	getFile ${imputationResultDir}/chunk$temp_chunk-chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	getFile ${imputationResultDir}/chunk$temp_chunk-chr${chr}_sampleChunk${sampleChunk}.imputed.map
done



alloutputsexist \
	${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.ped \
	${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.map

TO_RUN=$(echo "paste \\"; value=0; ls -1 ${imputationResultDir}/chunk*-chr${chr}_sampleChunk${sampleChunk}.imputed.ped | sort -n -k 1.$STUDY_LENGTH | while read CMD; do value=`expr $value + 1`; if [ $value -eq 1 ]; then echo "$CMD \\"; else echo "<(cut -d ' ' -f 7- $CMD) \\"; fi; done; echo "> ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.ped")

echo "PED Merging Script:"
echo $TO_RUN

${TO_RUN}

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	mv ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.ped ${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	putFile chr${chr}_sampleChunk${sampleChunk}.imputed.ped

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1
fi


TO_RUN=(echo "cat "; ls -1 ${imputationResultDir}/chunk*-chr${chr}_sampleChunk${sampleChunk}.imputed.map | sort -n -k 1.$STUDY_LENGTH | while read CMD; do echo "$CMD"; done; echo " > ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.map")

echo "MAP Merging script:"
echo $TO_RUN

$(TO_RUN)

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
        mv ${imputationResultDir}/~chr${chr}_sampleChunk${sampleChunk}.imputed.map ${imputationResultDir}/chr${chr}_sampleChunk${sampleChunk}.imputed.map
        putFile chr${chr}_sampleChunk${sampleChunk}.imputed.ped

else
  
        echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
        #Return non zero return code
        exit 1
fi



