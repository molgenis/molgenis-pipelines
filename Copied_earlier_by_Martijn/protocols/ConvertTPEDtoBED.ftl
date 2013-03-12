#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4


module load plink/1.07-x86_64

getFile ${resultsDir}/${plinkInput}.tped
getFile ${resultsDir}/${plinkInput}.tfam

plink --tfile ${resultsDir}/${plinkInput} --recode --make-bed --noweb --out ${resultsDir}/${plinkOutput}

putFile ${resultsDir}/${plinkOutput}.bed
putFile ${resultsDir}/${plinkOutput}.bim
putFile ${resultsDir}/${plinkOutput}.fam

