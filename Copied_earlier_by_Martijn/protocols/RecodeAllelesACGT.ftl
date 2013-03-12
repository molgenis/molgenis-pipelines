#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4


module load plink/1.07-x86_64

getFile ${resultsDir}/${plinkBEDInput}.bed
getFile ${resultsDir}/${plinkBEDInput}.bim
getFile ${resultsDir}/${plinkBEDInput}.fam


plink --bfile ${resultsDir}/${plinkBEDInput} --alleleACGT --make-bed --recode --noweb --out ${resultsDir}/${plinkBEDOutput}

putFile ${resultsDir}/${plinkBEDOutput}.bed
putFile ${resultsDir}/${plinkBEDOutput}.bim
putFile ${resultsDir}/${plinkBEDOutput}.fam

