#MOLGENIS ppn=1 mem=5gb walltime=00:20:00

#string tmpName
#string simulatedPhiXVariants
#string inSilicoConcordanceFile
#string project
#string logsDir
#string project
#string projectVariantsMergedSorted
#string intermediateDir

sleep 10

tail -3 ${simulatedPhiXVariants} > ${intermediateDir}/InSilico.txt

awk '
BEGIN{}
FNR==NR{
    k=$1"\t"$2
    a[k]=$4"\t"$5
    b[k]=$0
    c[k]=$4
    d[k]=$5
    next
}

{ k=$1"\t"$2
  lc=c[k]
  ld=d[k]
  # file1 file2
  if ((k in a) && (lc==$4) && (ld==$5)){
        print k,lc,ld
        }
}' ${intermediateDir}/InSilico.txt ${projectVariantsMergedSorted} > ${intermediateDir}/InSilicoConcordanceCheck.txt

count=`cat ${intermediateDir}/InSilicoConcordanceCheck.txt | wc -l`

if [ $count -ne 3 ]; then
    echo "Spiked phiX reads NOT found in sample ${project}" > ${inSilicoConcordanceFile}
else
    echo "Spiked phiX reads found in sample ${project}" > ${inSilicoConcordanceFile}
fi
