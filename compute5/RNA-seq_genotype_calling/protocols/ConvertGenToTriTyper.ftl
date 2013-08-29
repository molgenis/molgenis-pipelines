
genotypeFolder=${genotypeFolder}


sample=${genotypeFolder}/chr.sample
gen=

outDir="/target/gpfs2/gcc/home/dasha/data/projects/geuvadis/genotypes/FIN/test/"
mkdir -p ${outDir}

inDir="/target/gpfs2/gcc/home/dasha/data/projects/geuvadis/genotypes/FIN/rna-seq/gen/"
samples=${inDir}*sample
sample=${samples[0]}
echo -e "outputDir=${outDir}\ninputDir=${inDir}"

java -Xmx6g -jar
/target/gpfs2/gcc/home/dasha/scripts/genotyping/GenotypeCalling/dist/GenotypeCalling.jar
\
--mode genToTriTyper \
--nonimputed \
--in ${inDir} \
--out ${outDir} \
--sample ${sample} \
--pattern "fin_0.8_(chr)_CR0.8_maf0.01.sorted.gen"