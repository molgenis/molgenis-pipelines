#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string plinkVersion
#string convertVCFtoPlinkPrefix
#string mendelianErrorCheckDir
#string phasedFamilyOutputPrefix
#string mendelianErrorCheckOutputPrefix


echo "## "$(date)" Start $0"


${stage} plink/${plinkVersion}
${checkStage}

mkdir -p ${mendelianErrorCheckDir}


#Check if *.snp.me contains SNPs with mendelian errors, if true remove them from the plink BED/BIM data

#Count number of lines containing mendel error in *.snp.me file
mendelErrors=$(awk '{ if ($3 != "0") print $0}' FS="\t" ${mendelianErrorCheckOutputPrefix}.snp.me | wc -l)
count=$(($mendelErrors-1))

#Check if more than 0 lines were detected
if [ $mendelErrors > 0 ]
then
	echo "Detected $count mendelian errors. Starting analysis to remove those SNPs .."
	echo ""
	
	#Create file containing IDs to remove
	awk '{ if ($3 != "0") print $1}' FS="\t" ${mendelianErrorCheckOutputPrefix}.snp.me > ${mendelianErrorCheckOutputPrefix}.IDsToExclude.txt

	#Remove first line of exclude file in place
	sed -i '1,1d' ${mendelianErrorCheckOutputPrefix}.IDsToExclude.txt

	#Run plink to exclude variants with mendelian errors
	plink \
	--bfile ${convertVCFtoPlinkPrefix} \
	--exclude ${mendelianErrorCheckOutputPrefix}.IDsToExclude.txt \
	--out ${mendelianErrorCheckOutputPrefix} \
	--make-bed

else
	echo "No mendelian errors detected, nothing to remove."
	echo ""
	
	#Copy input plink BED/BIM data to new output directory
	cp ${convertVCFtoPlinkPrefix}.bed ${mendelianErrorCheckOutputPrefix}.bed
	cp ${convertVCFtoPlinkPrefix}.bim ${mendelianErrorCheckOutputPrefix}.bim
	cp ${convertVCFtoPlinkPrefix}.fam ${mendelianErrorCheckOutputPrefix}.fam

fi



cd ${mendelianErrorCheckDir}/
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.bed) > ${mendelianErrorCheckOutputPrefix}.bed.md5
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.bim) > ${mendelianErrorCheckOutputPrefix}.bim.md5
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.fam) > ${mendelianErrorCheckOutputPrefix}.fam.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "