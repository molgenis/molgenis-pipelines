#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string chiIntermediateDir
#string resultDir
#string forwardBins
#string reverseBins


#Echo parameter values
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "resultDir: ${resultDir}"
echo "forwardBins: ${forwardBins}"
echo "reverseBins: ${reverseBins}"


mkdir -p "${resultDir}/Diagnostiek"
mkdir -p "${resultDir}/All"
mkdir -p "${resultDir}/Data"


cp ${chiIntermediateDir}/*.pdf ${resultDir}/All
cp ${chiIntermediateDir}/*Diagnostiek* ${resultDir}/Diagnostiek
cp ${forwardBins} ${resultDir}/Data
cp ${reverseBins} ${resultDir}/Data