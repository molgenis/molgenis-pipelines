#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=08:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string stage
#string checkStage
#string fastqcVersion
#string tmpIntermediateDir
#string intermediateDir
#string peEnd1BarcodeFastQcZip
#string peEnd2BarcodeFastQcZip
#string srBarcodeFastQcZip

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "fastqcVersion: ${fastqcVersion}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQcZip: ${peEnd1BarcodeFastQcZip}"
echo "peEnd2BarcodeFastQcZip: ${peEnd2BarcodeFastQcZip}"
echo "srBarcodeFastQcZip: ${srBarcodeFastQcZip}"

sleep 10


alloutputsexist \
"${srBarcodeFastQcZip}"
        
getFile ${srBarcodeFqGz}



#Load module
${stage} fastqc/${fastqcVersion}
${checkStage}

#Make tmp directory
mkdir -p "${tmpIntermediateDir}"




fastqc ${srBarcodeFqGz} \
 -o ${tmpIntermediateDir}
        
#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
        echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
        mv ${tmpIntermediateDir}/* ${intermediateDir}
        putFile "${srBarcodeFastQcZip}"

        else
        echo -e "\nFailed to move FastQC results to ${intermediateDir}\n\n"
        exit -1
fi


