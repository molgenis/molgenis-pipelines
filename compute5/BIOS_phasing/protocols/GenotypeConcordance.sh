#MOLGENIS nodes=1 ppn=1 mem=40gb walltime=06:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string pyvcfVersion
#string vcftoolsVersion
#string RVersion
#string tabixVersion
#string comparisonFileDir
module load VCFtools/${vcftoolsVersion}
module load R/${RVersion}
module load tabix/${tabixVersion}
fvdProjectDir=/groups/umcg-bios/tmp04/umcg-fvandijk/projects/
rnaseq_rare_variants=${fvdProjectDir}RNA-seq_rare_variants/
comparison_files=${rnaseq_rare_variants}/comparison_files/
output_folder=${comparison_files}outputs_QC_filter_RNA_seq_pass_filtered/
#wgs_folder=${comparison_files}WGS_intersected/
wgs_folder=${rnaseq_rare_variants}GoNL_WGS_calls/
rnaseq_individual=${comparison_files}RNA_seq_individual_calls/
#wgs_postfix=.release5.raw_SNVs.intersect_PASS_only
wgs_postfix=.release5.NoMAFSelection

# INCASE IT IS RERUN, REMOVE PREVIOUS RESULT AS NEW DATA GETS APPENDED TO IT
#	merged calling
rm -f ${output_folder}RNA_unfiltered_count.txt
rm -f ${output_folder}RNA_filteredDP10_count.txt
rm -f ${output_folder}RNA_filteredDP20_count.txt
rm -f ${output_folder}RNA_filteredDP20_GQ20_count.txt
#	individual calling
rm -f ${output_folder}RNA_individual_calls_unfiltered_count.txt
rm -f ${output_folder}RNA_individual_calls_filteredDP10_count.txt
rm -f ${output_folder}RNA_individual_calls_filteredDP20_count.txt
rm -f ${output_folder}RNA_individual_calls_filteredDP20_GQ20_count.txt
rm -f ${output_folder}skipped*

rm -f ${output_folder}WGS_filtered_count.txt


mkdir -p ${output_folder}

for chr in {1..22}
	
do
    echo "Starting CHR ${chr}"
	#	bgzip and tabix all RNA-seq individual calls
	#	comment out if not needed
    if [ ! -f ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf.gz ]; then
        echo "bgzip ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf.gz"
    	bgzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf > ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf.gz
	    tabix -p vcf ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf.gz
    fi
	
	#	tabix
    if [ ! -f ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf.gz ]; then
        echo "bgzip ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf.gz"
	    bgzip -c ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf  > ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf.gz
    	tabix -p vcf ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf.gz
    fi
	#	WGS
	gunzip -c ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf.gz | grep 'PASS' | wc -l >> ${output_folder}WGS_filtered_count.txt
	#	unfiltered individual calling
	gunzip -c ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF.gg.vcf.gz | grep 'GT:AD' | wc -l >> ${output_folder}RNA_unfiltered_count.txt
	#	unfiltered merged
	gunzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf.gz |  grep 'GT:AD' | wc -l >> ${output_folder}RNA_individual_calls_unfiltered_count.txt

	for dp in 10 20
	do
		## Step 1: Filter 
		#	Without individual calling
		#	min mean dp is ${dp}
		vcftools --vcf ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF.gg.vcf \
			--min-meanDP ${dp} \
			--recode \
			--remove-filtered-geno-all \
			--out ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}

		bgzip -c ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode.vcf  > ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode.vcf.gz
		tabix -p vcf ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode.vcf.gz
	
	
		#	With individual calling
		vcftools --vcf ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf \
			--min-meanDP ${dp} \
			--recode \
			--remove-filtered-geno-all \
			--out ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}

		bgzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode.vcf  > ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode.vcf.gz
		tabix -p vcf ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode.vcf.gz
		
		
		##	Step 2: Read how many variants in WGS and RNA-seq
		#merged
		gunzip -c ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode.vcf.gz | grep 'GT:AD' | wc -l >> ${output_folder}RNA_filteredDP${dp}_count.txt
		#individual
		gunzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode.vcf.gz | grep 'GT:AD' | wc -l >> ${output_folder}RNA_individual_calls_filteredDP${dp}_count.txt
	
	
		##	Step 3: Compare
		#	without individual calling
		java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
			-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
			-D1 VCF \
			-d2 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode \
			-D2 VCF \
			-o ${output_folder}intersected_filter_DP${dp}${chr} \
			-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_DP${dp}${chr}.log

		#	with individual calling
		java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
			-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
			-D1 VCF \
			-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode \
			-D2 VCF \
			-o ${output_folder}intersected_individual_calling_filter_DP${dp}${chr} \
			-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_individal_calls_DP${dp}${chr}.log
	
		##	compare unified calling vs individual calling
		java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
			-d1 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP${dp}.recode \
			-D1 VCF \
			-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP${dp}.recode \
			-D2 VCF \
			-o ${output_folder}RNA_seq_merged_vs_individual_filter_DP${dp}${chr} \
			-s ${rnaseq_rare_variants}linking_file_RNA_seq.txt 2>&1 | tee ${output_folder}RNA_seq_merged_vs_individual_filter_DP${dp}${chr}.log
	
	done

	#	min mean dp is 20 and genotype quality is 20
	vcftools --vcf ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF.gg.vcf \
	--min-meanDP 20 \
	--minQ 20 \
	--recode \
	--remove-filtered-geno-all \
	--out ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20

	bgzip -c ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode.vcf  > ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode.vcf.gz
	tabix -p vcf ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode.vcf.gz

	#	filter in only PASS in WGS
	vcftools --vcf ${wgs_folder}gonl-abc_samples.chr${chr}.release5.raw_SNVs.intersect.vcf \
	--recode \
	--stdout \
	--remove-filtered-all > ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix}.vcf


	#	min mean dp is 20 and genotype quality is 20
	vcftools --vcf ${rnaseq_individual}mergeGVCFchr${chr}.gg.vcf \
	--min-meanDP 20 \
	--minQ 20 \
	--recode \
	--remove-filtered-geno-all \
	--out ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20

	bgzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode.vcf  > ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode.vcf.gz
	tabix -p vcf ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode.vcf.gz

	###############################################################

	gunzip -c ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode.vcf.gz | grep 'GT:AD' | wc -l >> ${output_folder}RNA_filteredDP20_GQ20_count.txt
	# individual 
	gunzip -c ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode.vcf.gz | grep 'GT:AD' | wc -l >> ${output_folder}RNA_individual_calls_filteredDP20_GQ20_count.txt

	

	##	Step 3: Compare
	#	without individual calling

	#	unfiltered RNA-seq WGS PASS filter
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
	-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
	-D1 VCF \
	-d2 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF.gg \
	-D2 VCF \
	-o ${output_folder}intersected_no_filter${chr} \
	-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_no_filter${chr}.log	

	#	mean DP 20 and GQ 20
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
	-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
	-D1 VCF \
	-d2 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode \
	-D2 VCF \
	-o ${output_folder}intersected_filter_DP20__minQC20${chr} \
	-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_DP20_GC20${chr}.log


	#	with individual calling

	#	unfiltered RNA-seq WGS PASS filter
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
		-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
		-D1 VCF \
		-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg \
		-D2 VCF \
		-o ${output_folder}intersected_individual_calling_no_filter${chr} \
		-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_individal_calls_no_filter${chr}.log

	#	mean DP 20 and GQ 20
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
		-d1 ${wgs_folder}gonl-abc_samples.chr${chr}${wgs_postfix} \
		-D1 VCF \
		-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode \
		-D2 VCF \
		-o ${output_folder}intersected_individual_calling_filter_DP20_GC20${chr} \
		-s ${rnaseq_rare_variants}linking_file.txt 2>&1 | tee ${output_folder}intersected_individal_calls_DP20_QC20${chr}.log


	##	compare unified calling vs individual calling

	#	 no filter
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
		-d1 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF.gg \
		-D1 VCF \
		-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg \
		-D2 VCF \
		-o ${output_folder}RNA_seq_merged_vs_individual_no_filter${chr} \
		-s ${rnaseq_rare_variants}linking_file_RNA_seq.txt 2>&1 | tee ${output_folder}RNA_seq_merged_vs_individual_no_filter${chr}.log


	#	 DP20 GQ20
	java -jar /groups/umcg-bios/tmp04/users/umcg-mjbonder/CompareGenotypeCalls-1.5-SNAPSHOT/CompareGenotypeCalls.jar \
		-d1 ${comparison_files}RNA_seq/chr${chr}.genotypeGVCF_filtered.gg_meanDP20_minQC20.recode \
		-D1 VCF \
		-d2 ${rnaseq_individual}mergeGVCFchr${chr}.gg_meanDP20_minQC20.recode \
		-D2 VCF \
		-o ${output_folder}RNA_seq_merged_vs_individual_filter_DP20_GQ20${chr} \
		-s ${rnaseq_rare_variants}linking_file_RNA_seq.txt 2>&1 | tee ${output_folder}RNA_seq_merged_vs_individual_filter_DP20_GQ20${chr}.log

    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_no_filter${chr}.log  >>  ${output_folder}skipped_merged_no_filter.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_DP10${chr}.log >> ${output_folder}skipped_merged_DP10.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_DP20${chr}.log >> ${output_folder}skipped_merged_DP20.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_DP20_GC20${chr}.log >> ${output_folder}skipped_merged_DP20_GQ20.txt

    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_individal_calls_no_filter${chr}.log >> ${output_folder}skipped_individual_no_filter.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_individal_calls_DP10${chr}.log >> ${output_folder}skipped_individual_DP10.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_individal_calls_DP20${chr}.log >> ${output_folder}skipped_individual_DP20.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}intersected_individal_calls_DP20_QC20${chr}.log >> ${output_folder}skipped_individual_DP20_GQ20.txt

    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}RNA_seq_merged_vs_individual_no_filter${chr}.log >> ${output_folder}skipped_individual_vs_merged_no_filter.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}RNA_seq_merged_vs_individual_filter_DP10${chr}.log >> ${output_folder}skipped_individual_vs_merged_DP10.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}RNA_seq_merged_vs_individual_filter_DP20${chr}.log >> ${output_folder}skipped_individual_vs_merged_DP20.txt
    awk -v x=$chr '/Number of SNPs compared:/{print x, "compared", $NF} /Skipped vars due to incosistant alleles:/{print x, "skipped", $NF}' ${output_folder}RNA_seq_merged_vs_individual_filter_DP20_GQ20${chr}.log >> ${output_folder}skipped_individual_vs_merged_DP20_GQ20.txt

done
##############################################################################################################################################

#	after done, remove all different filtered sets for RNA-seq
#rm ${comparison_files}RNA_seq/*_filtered*
#rm ${rnaseq_individual}*recode*

#	Step 4: append output files:

Rscript script_concatenate_variant_test.R

#	Step 5: Use R script to generate report plots and files

Rscript script_rMarkdown_render.R


