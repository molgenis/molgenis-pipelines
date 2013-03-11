#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4


module load plink/1.07-x86_64

getFile ${resultsDir}/${plinkBED1}.bed
getFile ${resultsDir}/${plinkBED1}.bim
getFile ${resultsDir}/${plinkBED1}.fam

getFile ${resultsDir}/${plinkBED2}.bed
getFile ${resultsDir}/${plinkBED2}.bim
getFile ${resultsDir}/${plinkBED2}.fam


plink --bfile ${resultsDir}/${plinkBED1} --bmerge ${resultsDir}/${plinkBED2}.bed ${resultsDir}/${plinkBED2}.bim ${resultsDir}/${plinkBED2}.fam --merge-mode 6 --noweb --out ${resultsDir}/plink_comparison.txt

