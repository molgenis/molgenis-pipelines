

for i in {1..22}
do

mkdir -p /groups/umcg-bios/tmp03/projects/phasing/jobs_smallChunks/filter_GQ20/chr$i/

while read line
do

CHR=`echo $line | awk '{print $1}' FS=","`
START=`echo $line | awk '{print $2}' FS=":" | awk '{print $1}' FS="-"`
END=`echo $line | awk '{print $2}' FS=":" | awk '{print $2}' FS="-"`
RESULTSDIR="/groups/umcg-bios/tmp03/projects/phasing/results_GQ20//shapeitSmallChunks/chr$CHR/"


echo "#!/bin/bash
#SBATCH --job-name=chr$CHR.$START.$END.BIOS_freeze2_ShapeitPhasing
#SBATCH --output=ShapeitPhasing.chr$CHR.$START.$END.out
#SBATCH --error=ShapeitPhasing.chr$CHR.$START.$END.err
#SBATCH --time=23:59:00
#SBATCH --cpus-per-task 4
#SBATCH --mem 8gb
#SBATCH --open-mode=append
#SBATCH --export=NONE
#SBATCH --get-user-env=30L
#SBATCH --qos=dev

set -e
set -u

ENVIRONMENT_DIR='.'


module load tabix/0.2.6-foss-2015b
module load shapeit/v2.r837-static
module list

echo \"## \"\$(date)\" Start \$0\"

mkdir -p $RESULTSDIR


#Run shapeit
# The shaping is scaffolded using the chip-based or wgs phased genotypes (--input-init). For data without this information (like
# vcfs from public rnaseq) this pipeline needs to be different OR it needs to be phased together with BIOS samples (using BIOS
# samples as scaffolding, but could give population problems)
if shapeit \\
 -call \\
 --input-gen /groups/umcg-bios/tmp03/projects/phasing/results_GQ20//beagle//BIOS_freeze2.chr$CHR.beagle.genotype.probs.gg.gen.gz \\
             /groups/umcg-bios/tmp03/projects/phasing/results_GQ20//beagle//BIOS_freeze2.chr$CHR.beagle.genotype.probs.gg.gen.sample \\
 --input-init /groups/umcg-bios/tmp03/projects/phasing/results_GQ20//beagle//BIOS_freeze2.chr$CHR.beagle.genotype.probs.gg.hap.gz \\
              /groups/umcg-bios/tmp03/projects/phasing/results_GQ20//beagle//BIOS_freeze2.chr$CHR.beagle.genotype.probs.gg.hap.sample \\
 --input-map /apps/data/www.shapeit.fr/genetic_map_b37//genetic_map_chr$CHR\_combined_b37.txt \\
 --input-scaffold /groups/umcg-lld/tmp03/projects/genotypingRelease3/selectionLldeep/lldeepPhased_RNA_IDs//chr_$CHR.haps \\
                  /groups/umcg-lld/tmp03/projects/genotypingRelease3/selectionLldeep/lldeepPhased_RNA_IDs//chr_$CHR.sample \\
 --input-thr 1.0 \\
 --thread 4 \\
 --window 0.1 \\
 --states 400 \\
 --states-random 200 \\
 --burn 0 \\
 --run 12 \\
 --prune 4 \\
 --main 20 \\
 --output-max $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.hap.gz \\
             $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.hap.gz.sample \\
 --output-log $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.log \\
 --input-from $START \\
 --input-to $END
then
 echo \"returncode: \$?\";
 cd $RESULTSDIR
 bname=\$(basename $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.hap.gz)
 md5sum \${bname} > \${bname}.md5
 bname=\$(basename $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.hap.gz.sample)
 md5sum \${bname} > \${bname}.md5
 bname=\$(basename $RESULTSDIR/BIOS_freeze2.chr$CHR.$START.$END.shapeit.phased.log)
 md5sum \${bname} > \${bname}.md5
 cd -
 echo \"succes moving files\";
fi

touch ShapeitPhasing.chr$CHR.$START.$END.sh.finished

echo \"## \"\$(date)\" ##  \$0 Done \"

">./jobs_smallChunks/filter_GQ20/chr$i/ShapeitPhasing.chr$CHR.$START.$END.sh

done</groups/umcg-bios/tmp03/projects/phasing/molgenis-pipelines_smallChunks/compute5/BIOS_phasing/chromosomes/chromosome_chunks_chr$i.csv

done
