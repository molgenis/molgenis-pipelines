#string pindelOutputVcf(merged)
#string projectIndelsMerged
#string indelsVcf
#string mergeSVspl
#string sortVCFpl
#string indelsMergedUnsortedVcf
#string indexFileFastaIndex


inputs "${pindelOutputVcf}"
inputs "${projectIndelsMerged}"
alloutputsexist \
"${indelsMergedSortedVcf}"

perl ${mergeSVspl} \
-pindelVCF ${pindelOutputVcf} \
-unifiedGenotyperVCF ${projectIndelsMerged} \
-outputVCF ${indelsMergedUnsortedVcf}

perl ${sortVCFpl} \
-fastaIndexFile ${indexFileFastaIndex} \
-inputVCF ${indelsMergedUnsortedVcf} \
-outputVCF ${indelsMergedSortedVcf}
