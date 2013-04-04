#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

getFile ${studyInputDir}/merged.ped
getFile ${studyInputDir}/merged.map

#Check if convertf is on path
hash convertf || PATH=$PATH:${tooldir}/EIG/

#Check if gnuplot is on path
hash gnuplot || PATH=$PATH:${gnuplot_path}

#Check if GNUPLOT_PS_DIR is defined
if [ -z "$GNUPLOT_PS_DIR" ]; then
    export GNUPLOT_PS_DIR=${gnuplot_path}/term/PostScript
fi  

mkdir -p ${resultDir}

#Creating parameters file
echo "
genotypename:    ${studyInputDir}/merged.ped
snpname:         ${studyInputDir}/merged.map
indivname:       ${studyInputDir}/merged.ped
outputformat:    EIGENSTRAT
genotypeoutname: ${resultDir}/~combined.eigenstratgeno
snpoutname:      ${resultDir}/~combined.snp
indivoutname:    ${resultDir}/~combined.ind
familynames:     NO
" > ${resultDir}/param.txt

#Convert from ped / map to eigen
${convertf} -p ${resultDir}/param.txt

alloutputsexist \
  ${resultDir}/combinedPca.pca \
  ${resultDir}/combinedPca.plot \
  ${resultDir}/combinedPca.eval \
  ${resultDir}/combinedPca.log


#Do the PCA
#We change the running directory because the pdf is exported at current dir
cd ${resultDir}; ${smartpca_perl} \
    -i ${resultDir}/~combined.eigenstratgeno \
    -a ${resultDir}/~combined.snp \
    -b ${resultDir}/~combined.ind \
    -k 10 \
    -o ${resultDir}/~combinedPca.pca \
    -p ${resultDir}/~combinedPca.plot \
    -e ${resultDir}/~combinedPca.eval \
    -l ${resultDir}/~combinedPca.log \
    -m 0 \
    -t 10 \
    -s 6 

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
	mv ${resultDir}/~combined.eigenstratgeno ${resultDir}/combined.eigenstratgeno
	mv ${resultDir}/~combined.snp ${resultDir}/combined.snp
	mv ${resultDir}/~combined.ind ${resultDir}/combined.ind
	mv ${resultDir}/~combinedPca.pca ${resultDir}/combinedPca.pca
	mv ${resultDir}/~combinedPca.plot ${resultDir}/combinedPca.plot
	mv ${resultDir}/~combinedPca.eval ${resultDir}/combinedPca.eval
	mv ${resultDir}/~combinedPca.log ${resultDir}/combinedPca.log
	mv ${resultDir}/~combinedPca.plot.pdf ${resultDir}/combinedPca.plot.pdf

	putFile ${resultDir}/combined.eigenstratgeno
	putFile ${resultDir}/combined.snp
	putFile ${resultDir}/combined.ind
	putFile ${resultDir}/combinedPca.pca
	putFile ${resultDir}/combinedPca.plot
	putFile ${resultDir}/combinedPca.eval
	putFile ${resultDir}/combinedPca.log
	putFile ${resultDir}/combinedPca.plot.pdf
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
