#MOLGENIS walltime=01:59:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_originalFiles
#string GIANT_workDir_studyDir
#string GIANT_workDir_outputLiftoverDir
#string chr
#string studyInputDir
#string outputFolder
#string outputFolderTmp
#string outputFolderChrDir
#string liftOverChainFile
#string liftOverUcscBin
#string plink
#string stage

#Echo parameter values
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}"
echo "GIANT_workDir_studyDir: ${GIANT_workDir_studyDir}"
echo "GIANT_workDir_outputLiftoverDir: ${GIANT_workDir_outputLiftoverDir}"
echo "chr: ${chr}" 
echo "studyInputDir: ${studyInputDir}" 
echo "outputFolder: ${outputFolder}"
echo "outputFolderTmp: ${outputFolderTmp}" 
echo "outputFolderChrDir: ${outputFolderChrDir}" 
echo "liftOverChainFile: ${liftOverChainFile}" 
echo "liftOverUcscBin: ${liftOverUcscBin}" 
echo "plink: ${plink}"

${stage} ${plink}

#make study directory with ped/map files per chromosome
if [ ! -d ${GIANT_workDir_studyDir} ]
then
	mkdir ${GIANT_workDir_studyDir}
fi

cp ${GIANT_workDir_originalFiles}/output.chrX.ped.female_only.ped ${GIANT_workDir_studyDir}/chrX.ped
cp ${GIANT_workDir_originalFiles}/output.chrX.map ${GIANT_workDir_studyDir}/chrX.map

if [ ! -d ${GIANT_workDir_outputLiftoverDir} ] 
then
	mkdir ${GIANT_workDir_outputLiftoverDir}
fi

### LIFTOVER hg18 --> hg19 ##

#Create output directories
mkdir -p $outputFolder
#mkdir -p $outputFolderChrDir
mkdir -p $outputFolderTmp

#Retrieve input Files
inputs $studyInputDir/chr$chr.ped
inputs $studyInputDir/chr$chr.map
getFile $studyInputDir/chr$chr.ped
getFile $studyInputDir/chr$chr.map

#create bed file based on map file
awk '{$5=$2;$2=$4;$3=$4+1;$1="chr"$1;print $1,$2,$3,$5}' OFS="\t" $studyInputDir/chr$chr.map > $outputFolderTmp/chr$chr.old.bed

#map to b37
${liftOverUcscBin} \
	-bedPlus=4 $outputFolderTmp/chr$chr.old.bed \
	$liftOverChainFile \
	$outputFolderTmp/chr$chr.new.bed \
	$outputFolderTmp/chr$chr.new.unmapped.txt

#create list of unmapped snps
awk '/^[^#]/ {print $4}' $outputFolderTmp/chr$chr.new.unmapped.txt > $outputFolderTmp/chr$chr.new.unmappedSnps.txt

#create mappings file used by plink
awk '{print $4, $2}' OFS="\t" $outputFolderTmp/chr$chr.new.bed > $outputFolderTmp/chr$chr.new.Mappings.txt 


#create new plink data without the unmapped snps                            
plink \
	--noweb \
	--file $studyInputDir/chr$chr \
	--recode \
	--out $outputFolderTmp/chr$chr.unordered \
	--exclude $outputFolderTmp/chr$chr.new.unmappedSnps.txt \
	--update-map $outputFolderTmp/chr$chr.new.Mappings.txt                        


#This simple run, reorder SNPs in case liftoering produced unorder positions
# /gcc/tools/plink-1.07-x86_64/plink --noweb --recode --file chr1 --out test

plink \
	--noweb \
	--file $outputFolderTmp/chr$chr.unordered  \
	--recode \
	--make-bed \
	--out $outputFolderTmp/~chr$chr
for tempFile in $outputFolderTmp/~chr$chr* ; do
	finalFile=`echo $tempFile | sed -e "s/~//g"`
	echo "Moving temp file: ${tempFile} to ${finalFile}"
	mv $tempFile $finalFile
	putFile $finalFile
done

echo -e "\nMoving resulting files to the final destination\n"
mv $outputFolderTmp/chr$chr.{bed,bim,fam} $outputFolder/

#LL data: change bim chromosome 23 -> chrX
perl -pi -e 's/^23/X/g' ${GIANT_workDir_outputLiftoverDir}/chrX.bim
