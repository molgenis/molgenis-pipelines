#MOLGENIS walltime=05:59:00 mem=8gb nodes=1 ppn=16 ### variables to help adding t$
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
#string yfiletxtExon
#string kfilebinMetaExon
#string yfilebinMetaExon
#string yfiletxtMetaExon
#string kfilebinGene
#string yfilebinGene
#string yfiletxtGene
#string kfilebinTranscript
#string yfilebinTranscript
#string yfiletxtTranscript
#string featureType
#string rasqualOutDir
#string featureChunkFile
#string CHR
#string regionsFile
#string GSLVersion
#string tabixVersion
#string minCoveragePerFeature
#string insertSize
#string featureChunkDir
#string rasqualFeatureChunkOutput
#string rasqualFeatureChunkPermutationOutput


echo "## "$(date)" ##  $0 Start "

getFile ${featureChunkFile}
getFile ${ASVCF}
getFile ${regionsFile}


${stage} GSL/${GSLVersion}
${stage} tabix/${tabixVersion}
${checkStage}


mkdir -p ${rasqualOutDir}/${featureType}/chr${CHR}/

echo LAST START >> ${rasqualFeatureChunkOutput}
if [ ${featureType} == "exon" ];
then
        kfilebin=${kfilebinExon}
        yfilebin=${yfilebinExon}
        yfiletxt=${yfiletxtExon}
        featureDir=${featureChunkDir}/exonlistChunks/
elif [ ${featureType} == "metaExon" ];
then
        kfilebin=${kfilebinMetaExon}
        yfilebin=${yfilebinMetaExon}
        yfiletxt=${yfiletxtMetaExon}
        featureDir=${featureChunkDir}/meta-exonlistChunksPerFeature/chr${CHR}/
elif [ ${featureType} == "gene" ];
then
        kfilebin=${kfilebinGene}
        yfilebin=${yfilebinGene}
        yfiletxt=${yfiletxtGene}
        #featureDir=${featureChunkDir}/genelistChunks/
        featureDir=${featureChunkDir}/genelistChunksPerFeature/
elif [ ${featureType} == "transcript" ];
then
        kfilebin=${kfilebinTranscript}
        yfilebin=${yfilebinTranscript}
        yfiletxt=${yfiletxtTranscript}
        featureDir=${featureChunkDir}/transcriptlistChunks/
else
        echo featureType must be transcript, exon or gene in parameter file
        exit
fi

rm -f ${rasqualFeatureChunkOutput}
rm -f ${rasqualFeatureChunkPermutationOutput}

#Copy feature file, bgzip and tabix it (this to reduce number of files on shared storage space)
cp $featureDir/${featureChunkFile} $TMPDIR/${featureChunkFile}
bgzip -c $TMPDIR/${featureChunkFile} > $TMPDIR/${featureChunkFile}.gz
tabix -s 1 -b 2 -e 3 $TMPDIR/${featureChunkFile}.gz

#Run analysis
window=$((${cisWindow}/2)) # 1Mb
samples_num=$(awk -F'\t' '{print NF-1; exit}' ${yfiletxt})
cutoff=$((samples_num * ${minCoveragePerFeature}))
Top=$(tabix ${ASVCF} ${CHR}: | tail -n 1 | cut -f 2)
while read region;do
while read line;do
		echo "Analyzing feature: $line";
        #INIT#########################
        array=($line)
        id=$(echo $line| cut -f1-5,7-9,13,16)
        chr="${array[0]}"
        start="${array[1]}"
        end="${array[2]}"
        featureStarts="${array[13]}"
        featureEnds="${array[14]}"
        seq_len="${array[12]}"
        line_number="${array[15]}"
        Cutoff_for_this=$((cutoff * (seq_len/${insertSize})))
        Coverage=$(sed "${line_number}q;d" ${yfiletxt} | awk '{ for(i=2; i<=NF;i++) j+=$i; print j; j=0 }') 
        if (( start < window )); then L=1
                else L=$((start - window)); fi
        if (( (start + window) > Top )); then R=$Top
                else R=$((start + window)); fi
        Totalsnps="$(tabix ${ASVCF} $chr:$L-$R | wc -l)"
        #PREFILTERS###########################################
#       if (( Coverage < Cutoff_for_this)); then continue; fi
        ######################################################
        tabix ${ASVCF} $chr:$L-$R | ${RASQUALDIR}/bin/rasqual --force -y ${yfilebin} -k ${kfilebin} -n $samples_num -j $line_number -l $Totalsnps -m $Totalsnps -s $featureStarts -e $featureEnds -f "$id Output:" --n-threads 16 >> ${rasqualFeatureChunkOutput}
        tabix ${ASVCF} $chr:$L-$R | ${RASQUALDIR}/bin/rasqual --force -y ${yfilebin} -k ${kfilebin} -n $samples_num -j $line_number -l $Totalsnps -m $Totalsnps -s $featureStarts -e $featureEnds -f "$id Output:" --n-threads 16 -r >> ${rasqualFeatureChunkPermutationOutput}
done < <(tabix $TMPDIR/${featureChunkFile}.gz "$region" )
done < <(awk 'F"\t" $($1 == ${CHR}) {printf ("%s:%s-%s\n", $1, $2, $3)}' ${regionsFile})


#Putfile the results
if [ -f "${rasqualFeatureChunkOutput}" ];
then
 echo "returncode: $?"; 
 putFile ${rasqualFeatureChunkOutput}
 putFile ${rasqualFeatureChunkPermutationOutput}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi


echo "## "$(date)" ##  $0 Done "

