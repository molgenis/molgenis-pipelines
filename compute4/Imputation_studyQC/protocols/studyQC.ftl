#MOLGENIS nodes=1 cores=1 mem=8

#FOREACH study,chr


#Parameter mapping
chr="${chr}"
studyInputDir="${studyInputDir}"
outputFolder="${outputFolder}"
outputTriTyperDir="${outputTriTyperDir}"
outputTriTyperChrDir="${outputTriTyperChrDir}"
outputTriTyperChrTmpDir="${outputTriTyperChrTmpDir}"
outputPedMapForwardDir="${outputPedMapForwardDir}"
outputPedMapForwardChrDir="${outputPedMapForwardChrDir}"
outputPedMapForwardChrTmpDir="${outputPedMapForwardChrTmpDir}"
triTyperReferenceFolder="${triTyperReferenceFolder}"
triTyperReferenceChrRsIDs="${triTyperReferenceChrRsIDs}"
imputationToolJar="${imputationToolJar}"
imputationToolVersion="${imputationToolVersion}"
javaVersion="${javaVersion}"

${stage} jdk/${javaVersion}
${stage} imputationTool/${imputationToolVersion}

<#noparse>

#Echo parameter values
echo "chr: ${chr}"
echo "outputFolder: ${outputFolder}"
echo "studyInputDir: ${studyInputDir}"
echo "triTyperReferenceFolder: ${triTyperReferenceFolder}"
echo "triTyperReferenceChrRsIDs: ${triTyperReferenceChrRsIDs}"
echo "outputTriTyperDir: ${outputTriTyperDir}"
echo "outputTriTyperChrDir: ${outputTriTyperChrDir}"
echo "outputTriTyperChrTmpDir: ${outputTriTyperChrTmpDir}"
echo "outputPedMapForwardDir: ${outputPedMapForwardDir}"
echo "outputPedMapForwardChrDir: ${outputPedMapForwardChrDir}"
echo "outputPedMapForwardChrTmpDir: ${outputPedMapForwardChrTmpDir}"
echo "imputationToolJar: ${imputationToolJar}"
echo "imputationToolVersion: ${imputationToolVersion}"
echo "javaVersion: ${javaVersion}"


#Create output directories
mkdir -p $outputTriTyperDir
mkdir -p $outputTriTyperChrDir
mkdir -p $outputPedMapForwardDir


#Convert study PED/MAP to TriTyper format
java -jar $imputationToolJar \
--mode pmtt \
--in  $studyInputDir/chr$chr \
--out $outputTriTyperChrTmpDir

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode ImputationTool: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then

	echo -e "\nStudy PED/MAP to TriTyper finished succesfull. Moving temp files to final.\n\n"
	mv $outputTriTyperChrTmpDir $outputTriTyperChrDir
	putFile "$outputTriTyperChrDir/GenotypeMatrix.dat"
    putFile "$outputTriTyperChrDir/Individuals.txt"
    putFile "$outputTriTyperChrDir/PhenotypeInformation.txt"
    putFile "$outputTriTyperChrDir/SNPMappings.txt"
    putFile "$outputTriTyperChrDir/SNPs.txt"

else
	echo -e "\nFailed to convert PED/MAP to $outputTriTyperChrDir/~chr${chr}\n\n"
	exit -1
fi


#Align study data to reference
java -Xmx8g -jar $imputationToolJar \
--mode ttpmh \
--in $outputTriTyperChrDir \
--hap $triTyperReferenceChrRsIDs \
--out $outputPedMapForwardChrTmpDir \
&> $outputPedMapForwardChrTmpDir/chr$chr.out

#Get return code from last program call
returnCode=$?

echo "returnCode ImputationTool: ${returnCode}"

if [ $returnCode -eq 0 ]
then

	echo -e "\nAlign study data to reference finished succesfull. Moving temp files to final.\n\n"
	mv $outputPedMapForwardChrTmpDir $outputPedMapForwardChrDir
	putFile "$outputPedMapForwardChrDir/chr$chr.dat"
	putFile "$outputPedMapForwardChrDir/chr$chr.map"
	putFile "$outputPedMapForwardChrDir/chr$chr.markersbeagleformat"
##	putFile "$outputPedMapForwardChrDir/chr$chr.ped"
	putFile "$outputPedMapForwardChrDir/chr$chr.out"
	putFile "$outputPedMapForwardChrDir/exportlog.txt"

else
	echo -e "\nFailed to aligned study data to reference to $outputPedMapForwardChrDir/~chr${chr}\n\n"
	exit -1
fi


#Fix sampleIDs
mv $outputPedMapForwardChrDir/chr${chr}.ped $outputPedMapForwardChrDir/chr${chr}_tmp.ped
        
awk '
    
	{
        
		indexFirstDash = index($2, "-")
        sampleId = substr($2, indexFirstDash + 1)
        famId = substr($2, 1,  indexFirstDash - 1)
            
        $1 = famId
        $2 = sampleId
        print $0
            
	}
    
' < $outputPedMapForwardChrDir/chr${chr}_tmp.ped > $outputPedMapForwardChrDir/~chr${chr}.ped

echo "returnCode ImputationTool: ${returnCode}"

if [ $returnCode -eq 0 ]
then

	echo -e "\nFixing sampleIDs finished succesfull. Moving temp files to final.\n\n"
	mv $outputPedMapForwardChrDir/~chr${chr}.ped $outputPedMapForwardChrDir/chr${chr}.ped
	putFile "$outputPedMapForwardChrDir/chr$chr.ped"

else
	echo -e "\nFailed to fix sampleIDs to $outputPedMapForwardChrDir/~chr${chr}\n\n"
	exit -1
fi


echo -e "\nFinished study QC for chromosome $chr\n\n"

</#noparse>