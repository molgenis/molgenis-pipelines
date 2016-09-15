#!bin/bash
#MOLGENIS walltime=3-23:59:00 mem=8gb nodes=1 ppn=16 ### variables to help adding t$
#string project
###
#string stage
#string checkStage
#string projectDir
#string ASVCF
#string RASQUALDIR
#string cisWindow
#string kfilebinExon
#string yfilebinExon
#string kfilebinGene
#string yfilebinGene
#string yfiletxtExon
#string yfiletxtGene
#string featureType
#string rasqualOutDir
#string featureFileExon
#string featureFileGene
#string CHR
#string regionsFile
#string GSLVersion
#string tabixVersion
#string minCoveragePerFeature
#string insertSize
################################
echo "## "$(date)" ##  $0 Start "
################################

${stage} GSL/${GSLVersion}
${stage} tabix/${tabixVersion}


mkdir -p ${rasqualOutDir}/${featureType}
echo LAST START >> ${rasqualOutDir}/${featureType}/${CHR}region_Rasqual_Output.txt
if [ ${featureType} == "exon" ]; then
	kfilebin=${kfilebinExon}
	yfilebin=${yfilebinExon}
	yfiletxt=${yfiletxtExon}
	featureFile=${featureFileExon}
elif [ ${featureType} == "gene" ]; then
	kfilebin=${kfilebinGene}
	yfilebin=${yfilebinGene}
	yfiletxt=${yfiletxtGene}
	featureFile=${featureFileGene}
else
	echo featureType must be exon or gene in parameter file
	exit
fi

rm -f ${rasqualOutDir}/${featureType}/${CHR}region_Rasqual_Output.txt
rm -f ${rasqualOutDir}/${featureType}/${CHR}region_Rasqual_Output_permutation.txt
window=$((${cisWindow}/2)) # 1Mb
samples_num=$(awk -F'\t' '{print NF-1; exit}' ${yfiletxt})
cutoff=$((samples_num * ${minCoveragePerFeature}))
Top=$(tabix ${ASVCF} ${CHR}: | tail -n 1 | cut -f 2)
while read region;do
while read line;do
	#INIT#########################
	array=($line)
	id=$(echo $line| cut -f1-5,7-9,13,16)
	chr="${array[0]}"
	start="${array[1]}"
	end="${array[2]}"
	featureStarts="${array[14]}"
	featureEnds="${array[15]}"
	seq_len="${array[12]}"
	line_number="${array[16]}"
	Cutoff_for_this=$((cutoff * (seq_len/${insertSize})))
	Coverage=$(sed "${line_number}q;d" ${yfiletxt} | awk '{ for(i=2; i<=NF;i++) j+=$i; print j; j=0 }') 
	if (( start < window )); then L=1
		else L=$((start - window)); fi
	if (( (start + window) > Top )); then R=$Top
		else R=$((start + window)); fi
	Totalsnps="$(tabix ${ASVCF} $chr:$L-$R | wc -l)"
	#PREFILTERS###########################################
#	if (( Coverage < Cutoff_for_this)); then continue; fi
	######################################################
tabix ${ASVCF} $chr:$L-$R | ${RASQUALDIR}/bin/rasqual -y ${yfilebin} -k ${kfilebin} -n $samples_num -j $line_number -l $Totalsnps -m $Totalsnps -s $featureStarts -e $featureEnds -f "$id Output:" --n-threads 16 >> ${rasqualOutDir}/${featureType}/${CHR}region_Rasqual_Output.txt
	tabix ${ASVCF} $chr:$L-$R | ${RASQUALDIR}/bin/rasqual -y ${yfilebin} -k ${kfilebin} -n $samples_num -j $line_number -l $Totalsnps -m $Totalsnps -s $featureStarts -e $featureEnds -f "$id Output:" --n-threads 16 -r >> ${rasqualOutDir}/${featureType}/${CHR}region_Rasqual_Output_permutation.txt
done < <(tabix ${featureFile} "$region" )
done < <(awk -F '\t' '$1 == ${CHR} {printf ("%s:%s-%s\n", $1, $2, $3)}' ${regionsFile})
################################
echo "## "$(date)" ##  $0 Done "
################################
