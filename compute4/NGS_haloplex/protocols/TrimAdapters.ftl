#MOLGENIS walltime=15:00:00 nodes=1 cores=1 mem=4
#TARGETS

/target/gpfs2/gcc/tools/ea-utils.1.1.2-537/fastq-mcf \
-s 1.5 \
-t 0.05 \
Illumina_TruSeq_adapters.fa \
130521_SN163_0494_AC20FTACXX_L8_TGAAGA_1.fq \
130521_SN163_0494_AC20FTACXX_L8_TGAAGA_2.fq \
-o output1_s1.5_t0.05.txt \
-o output2_s1.5_t0.05.txt