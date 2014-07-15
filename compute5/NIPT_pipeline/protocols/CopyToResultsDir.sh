#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string chiIntermediateDir
#string resultDir


#Echo parameter values
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "resultDir: ${resultDir}"


mkdir -p ${resultDir}

cp ${chiIntermediateDir}/*.pdf ${resultDir}
