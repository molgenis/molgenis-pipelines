#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string chiIntermediateDir
#string resultDir


#Echo parameter values
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "resultDir: ${resultDir}"


mkdir -p "${resultDir}/Diagnostiek"
mkdir -p "${resultDir}/All"

cp ${chiIntermediateDir}/*.pdf ${resultDir}/All
cp ${chiIntermediateDir}/*Diagnostiek* ${resultDir}/Diagnostiek
