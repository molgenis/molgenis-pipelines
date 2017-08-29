#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string shapeitVersion
#string convertVCFtoPlinkPrefix
#string phasedFamilyOutputDir




echo "## "$(date)" Start $0"


${stage} shapeit/${shapeitVersion}
${checkStage}

mkdir -p ${phasedFamilyOutputDir}



module load shapeit/v2.r837-static


        
        
shapeit -B ./test/testProject.5GPM_1510.merged.filtered.chr20 \
-M /apps/data/www.shapeit.fr/genetic_map_b37/genetic_map_chr20_combined_b37.txt \
--input-ref /groups/umcg-gonl/tmp04/reference/test.chr20.hap.gz \
/groups/umcg-gonl/tmp04/reference/test.chr20.legend.gz \
/groups/umcg-gonl/tmp04/reference/test.chr20.samples \
--duohmm \
-W 5 \
-O output.test




shapeit -B gwas-nomendel \
        -M genetic_map.txt \
        --input-ref reference.haplotypes.gz reference.legend.gz reference.sample \
        --duohmm \
        -W 5 \
        --output-max gwas-duohmm \
        --output-graph gwas-duohmm.graph
        
        --no-mcmc ?

