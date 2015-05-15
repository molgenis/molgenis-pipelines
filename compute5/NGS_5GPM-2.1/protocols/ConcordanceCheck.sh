#MOLGENIS walltime=01:00:00 nodes=1 ppn=4 mem=6gb

#string finalReport
#string sampleConcordanceFile
#string sample
#string externalSampleID
#string familyList
#string finalReportTmpDir
#string arrayTmpMap
#string arrayMapFile
#string toolDir
#string tempDir
#string resDir
#string sampleMergedBam
#string indexFile
#string dbSNPExSiteAfter129Vcf

if test ! -e ${finalReport};
then
	echo "name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance" > ${sampleConcordanceFile}
	echo "[1] NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA" >> ${sampleConcordanceFile} 
else
	#Check finalReport on "missing" alleles. Also, see if we can fix missing alleles somewhere in GenomeStudio
	awk '{ if ($3 != "-" || $4 != "-") print $0};' ${finalReport} \
	> ${sample}_FinalReport.txt.tmp
	
	##Push sample belonging to family "1" into list.txt
	echo '1 ${externalSampleID}' > ${familyList}
	
	#########################################################################
	#########################################################################
	#########################################################################
	# Use 'probe positions' to check whether the array file / final report is in build 36 or build 37.
	# In some cases the the position is erroneously one too small. In those cases, we add one to all positions in the array file / final report.
	
	# Load ten rs-ids and positions of ten probes that should be present on build 36 and also on build 37.
	# The difference in positions between none of the probes on b36 and b37 is 1.
	# Therefore, we can safely test whether a position matches on position n or n+1...
	
	rs[0]=rs4830576
	b36[0]=8245875
	b37[0]=8285875
	rs[1]=rs922257
	b36[1]=20391000
	b37[1]=20481079
	rs[2]=rs2168861
	b36[2]=31773234
	b37[2]=31863313
	rs[3]=rs5918076
	b36[3]=40718890
	b37[3]=40833946
	rs[4]=rs5936538
	b36[4]=69241401
	b37[4]=69324676
	rs[5]=rs4826938
	b36[5]=105496014
	b37[5]=105609358
	rs[6]=rs2208263
	b36[6]=115330016
	b37[6]=115415988
	rs[7]=rs1279816
	b36[7]=123183295
	b37[7]=123355614
	rs[8]=rs370713
	b36[8]=138470059
	b37[8]=138642393
	rs[9]=rs2266828
	b36[9]=149374751
	b37[9]=149624093
	
	# Find out which build was used. This info is stored in $build (build36, build37, N/A, ERROR)
	build="N/A"
	
	# Find out whether we have to increase all positions in the array file with 1.
	# Store this in the variable $increase1 ("true", "false")
	increase1="false"
	
	i=0
	ready=""
	while [ -z $ready ]
	do
	    position=`awk '$1 == "'${rs[$i]}'" {print $7}' ${sample}_FinalReport.txt.tmp`

		echo "${rs[$i]} has position ${position}"

	    # does the probe exist in this file?
	    if [ ! -z $position ]
	    then
	        ready="ready"
	
	        if [ ${position//$'\r'} == ${b36[$i]} ]
	        then
	            # we are on build 36                                                                                                                                           
	            build="build36"
	        elif  [ ${position//$'\r'} == ${b37[$i]} ]
	        then
	          	# we are on build 37
				build="build37"
	        elif [ $((${position//$'\r'} + 1)) == ${b36[$i]} ]
			then
	            # we are on build 36 (after increasing position with 1)                                                                                                                                         
	            build="build36"
	            increase1="true"
	        elif  [ $((${position//$'\r'} + 1)) == ${b37[$i]} ]
	        then
	          	# we are on build 37 (after increasing position with 1)
				build="build37"
				increase1="true"
			else
            	# we are neither on build 36 nor on build 37, according to this test                                                                                           
				build="ERROR"
			fi
	    fi
	    
	    # stop if we have tested all probes
	    if [ ${#rs[@]} -le $(($i+1)) ]
	    then
	        ready="ready"
	    fi
	
	    # increase counter
	    i=$[$i+1]
	done
	
	# Now copy the array file / final report to the tmp dir
	# Or, if increase1 == "true" then use awk to add one to the positions and redirect standard out to tmp dir
	
	if [ $increase1 == "false" ]
	then
		cp ${sample}_FinalReport.txt.tmp ${finalReportTmpDir}
	elif [ $increase1 == "true" ]
	then
		awk '{$7=$7+1; print $1,$2,$3,$4,$5,$6,$7}' OFS="\t" ${sample}_FinalReport.txt.tmp > ${finalReportTmpDir} 
	else
		echo "ERROR, variable increase1 should be either false or true"
	fi
	
	
	#########################################################################
	#########################################################################
	#########################################################################
	
	##Create .fam, .lgen and .map file from sample_report.txt
	sed -e '1,10d' ${finalReportTmpDir} | awk '{print "1",$2,"0","0","0","1"}' | uniq > ${sample}.concordance.fam
	sed -e '1,10d' ${finalReportTmpDir} | awk '{print "1",$2,$1,$3,$4}' | awk -f ${toolDir}/scripts/RecodeFRToZero.awk > ${sample}.concordance.lgen
	sed -e '1,10d' ${finalReportTmpDir} | awk '{print $6,$1,"0",$7}' OFS="\t" | sort -k1n -k4n | uniq > ${arrayTmpMap}
	grep -P '^[123456789]' ${arrayTmpMap} | sort -k1n -k4n > ${arrayMapFile}
	grep -P '^[X]\s' ${arrayTmpMap} | sort -k4n >> ${arrayMapFile}
	grep -P '^[Y]\s' ${arrayTmpMap} | sort -k4n >> ${arrayMapFile}
	
	#?# MD vraagt: wat doen --lfile en --out, en horen die gelijk te zijn?
	##Create .bed and other files (keep sample from sample_list.txt).
	
	module load plink/1.07-x86_64
	module list
	
	plink \
	--lfile ${sample}.concordance \
	--recode \
	--out ${sample}.concordance \
	--keep ${familyList}
	
	module unload plink
	module load plink/1.08
	module list
	
	##Create genotype VCF for sample
	plink108 \
	--recode-vcf \
	--ped ${sample}.concordance.ped \
	--map ${arrayMapFile} \
	--out ${sample}.concordance
	
	##Rename plink.vcf to sample.vcf
	mv ${sample}.concordance.vcf ${sample}.genotypeArray.vcf
	
	##Replace chr23 and 24 with X and Y
    perl -pi -e 's/^23/X/' ${sample}.genotypeArray.vcf
    perl -pi -e 's/^24/Y/' ${sample}.genotypeArray.vcf
	
	##Remove family ID from sample in header genotype VCF
	perl -pi -e 's/1_${externalSampleID}/${externalSampleID}/' ${sample}.genotypeArray.vcf
	
	##Create binary ped (.bed) and make tab-delimited .fasta file for all genotypes
	sed -e 's/chr//' ${sample}.genotypeArray.vcf | awk '{OFS="\t"; if (!/^#/){print $1,$2-1,$2}}' \
	> ${sample}.genotypeArray.bed
	
	####################################
	if [ $build == "build36" ]
	then # File is on build36

		module load BEDTools/Version-2.11.2
		module list

		##Create tabular fasta from bed
		fastaFromBed \
		-fi ${resDir}/b36/hs_ref_b36.fasta \
		-bed ${sample}.genotypeArray.bed \
		-fo ${sample}.genotypeArray.fasta -tab
	
		##Align vcf to reference AND DO NOT FLIP STRANDS!!! (genotype data is already in forward-forward format) If flipping is needed use "-f" command before sample.genotype_array.vcf
		perl ${toolDir}/scripts/align-vcf-to-ref.pl \
		${sample}.genotypeArray.vcf \
		${sample}.genotypeArray.fasta \
		${sample}.genotypeArray.aligned_to_ref.vcf \
		> ${sample}.genotypeArray.aligned_to_ref.vcf.out
	
		module load GATK/1.0.5069
		module list
	
		##Lift over sample.genotype_array.aligned_to_ref.vcf from build 36 to build 37
		liftOverVCF.pl \
		-vcf ${sample}.genotypeArray.aligned_to_ref.vcf \
		-gatk $GATK_HOME/.. \
		-chain ${resDir}/b36/chainfiles/b36ToHg19.broad.over.chain \
		-newRef ${resDir}/hg19/indices/human_g1k_v37 \
		-oldRef ${resDir}/b36/hs_ref_b36 \
		-tmp ${tempDir} \
		-out ${sample}.genotypeArray.aligned_to_ref.lifted_over.vcf
	
		##Some GATK versions sort header alphabetically, which results in wrong individual genotypes. So cut header from "original" sample.genotype_array.vcf and replace in sample.genotype_array.aligned_to_ref.lifted_over.out
		head -3 ${sample}.genotypeArray.vcf > ${sample}.genotypeArray.header.txt
	
		sed '1,4d' ${sample}.genotypeArray.aligned_to_ref.lifted_over.vcf \
		> ${sample}.genotypeArray.headerless.vcf
	
		cat ${sample}.genotypeArray.header.txt \
		${sample}.genotypeArray.headerless.vcf \
		> ${sample}.genotypeArray.updated.header.vcf
	
		##Create interval_list of CHIP SNPs to call SNPs in sequence data on
		perl ${toolDir}/scripts/iChip_pos_to_interval_list.pl \
		${sample}.genotypeArray.updated.header.vcf \
		${sample}.genotypeArray.updated.header.interval_list
		
		module unload GATK
		module load GATK/1.2-1-g33967a4
		module list
	
		###THESE STEPS USE NEWER VERSION OF GATK THAN OTHER STEPS IN ANALYSIS PIPELINE!!!
		##Call SNPs on all positions known to be on array and output VCF (including hom ref calls)
		java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
		-l INFO \
		-T UnifiedGenotyper \
		-R ${indexFile} \
		-I ${sampleMergedBam} \
		-o ${sample}.concordance.allSites.vcf \
		-stand_call_conf 30.0 \
		-stand_emit_conf 10.0 \
		-out_mode EMIT_ALL_SITES \
		-L ${sample}.genotypeArray.updated.header.interval_list
	
		##Change FILTER column from GATK "called SNPs". All SNPs having Q20 & DP10 change to "PASS", all other SNPs are "filtered" (not used in concordance check)
		perl ${toolDir}/scripts/change_vcf_filter.pl \
		${sample}.concordance.allSites.vcf \
		${sample}.concordance.q20.dp10.vcf 10 20
	
		##Calculate condordance between genotype SNPs and GATK "called SNPs"
		java -Xmx2g -Djava.io.tmpdir=${tempDir} -jar ${toolDir}/GATK-1.2-1-g33967a4/dist/GenomeAnalysisTK.jar \
		-T VariantEval \
		-eval:eval,VCF ${sample}.concordance.q20.dp10.vcf \
		-comp:comp_immuno,VCF ${sample}.genotypeArray.updated.header.vcf \
		-o ${sample}.concordance.q20.dp10.eval \
		-R ${indexFile} \
		-D:dbSNP,VCF ${dbSNPExSiteAfter129Vcf} \
		-EV GenotypeConcordance
	
		##Create concordance output file with header
		echo 'name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance' \
		> ${sampleConcordanceFile}
	
		module unload GATK
		module load GATK/1.3-24-gc8b1c92
		module list
	
		##Retrieve name,step,#SNPs,%dbSNP,Ti/Tv known,Ti/Tv Novel,Non-Ref Sensitivity,Non-Ref discrepancy,Overall concordance from sample.q20_dp10_concordance.eval
		##Don't forget to add .libPaths("/target/gpfs2/gcc/tools/GATK-1.3-24-gc8b1c92/public/R") to your ~/.Rprofile
		Rscript ${toolDir}/scripts/extract_info_GATK_variantEval_V3.R \
		--in ${sample}.concordance.q20.dp10.eval \
		--step q20_dp10_concordance \
		--name ${externalSampleID} \
		--comp comp_immuno \
		--header >> ${sampleConcordanceFile}
	fi

	if [ $build == "build37" ]
	then
		###################################
		#Arrayfile is on build 37
		
		module load BEDTools/Version-2.11.2
		module list
		
		##Create tabular fasta from bed
		fastaFromBed \
		-fi ${indexFile} \
		-bed ${sample}.genotypeArray.bed \
		-fo ${sample}.genotypeArray.fasta -tab
		
		##Align vcf to reference AND DO NOT FLIP STRANDS!!! (genotype data is already in forward-forward format) If flipping is needed use "-f" command before sample.genotype_array.vcf
		perl ${toolDir}/scripts/align-vcf-to-ref.pl \
		${sample}.genotypeArray.vcf \
		${sample}.genotypeArray.fasta \
		${sample}.genotypeArray.aligned_to_ref.vcf \
		> ${sample}.genotypeArray.aligned_to_ref.vcf.out
	
		##Some GATK versions sort header alphabetically, which results in wrong individual genotypes. So cut header from "original" sample.genotype_array.vcf and replace in sample.genotype_array.aligned_to_ref.lifted_over.out
		head -3 ${sample}.genotypeArray.vcf > ${sample}.genotypeArray.header.txt
	
		sed '1,3d' ${sample}.genotypeArray.aligned_to_ref.vcf \
		> ${sample}.genotypeArray.headerless.vcf
	
		cat ${sample}.genotypeArray.header.txt \
		${sample}.genotypeArray.headerless.vcf \
		> ${sample}.genotypeArray.updated.header.vcf
	
		##Create interval_list of CHIP SNPs to call SNPs in sequence data on
		perl ${toolDir}/scripts/iChip_pos_to_interval_list.pl \
		${sample}.genotypeArray.updated.header.vcf \
		${sample}.genotypeArray.updated.header.interval_list
	
		module unload GATK
		module load GATK/1.2-1-g33967a4
		module list
	
		###THESE STEPS USE NEWER VERSION OF GATK THAN OTHER STEPS IN ANALYSIS PIPELINE!!!
		##Call SNPs on all positions known to be on array and output VCF (including hom ref calls)
		java -Xmx4g -jar $GATK_HOME/GenomeAnalysisTK.jar \
		-l INFO \
		-T UnifiedGenotyper \
		-R ${indexFile} \
		-I ${sampleMergedBam} \
		-o ${sample}.concordance.allSites.vcf \
		-stand_call_conf 30.0 \
		-stand_emit_conf 10.0 \
		-out_mode EMIT_ALL_SITES \
		-L ${sample}.genotypeArray.updated.header.interval_list
	
		##Change FILTER column from GATK "called SNPs". All SNPs having Q20 & DP10 change to "PASS", all other SNPs are "filtered" (not used in concordance check)
		perl ${toolDir}/scripts/change_vcf_filter.pl \
		${sample}.concordance.allSites.vcf \
		${sample}.concordance.q20.dp10.vcf 10 20
	
		##Calculate condordance between genotype SNPs and GATK "called SNPs"
		java -Xmx2g -Djava.io.tmpdir=${tempDir} -jar ${toolDir}/GATK-1.2-1-g33967a4/dist/GenomeAnalysisTK.jar \
		-T VariantEval \
		-eval:eval,VCF ${sample}.concordance.q20.dp10.vcf \
		-comp:comp_immuno,VCF ${sample}.genotypeArray.updated.header.vcf \
		-o ${sample}.concordance.q20.dp10.eval \
		-R ${indexFile} \
		-D:dbSNP,VCF ${dbSNPExSiteAfter129Vcf} \
		-EV GenotypeConcordance
	
		##Create concordance output file with header
		echo 'name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance' \
		> ${sampleConcordanceFile}
	
		module unload GATK
		module load GATK/1.3-24-gc8b1c92
		module list
		
		##Retrieve name,step,#SNPs,%dbSNP,Ti/Tv known,Ti/Tv Novel,Non-Ref Sensitivity,Non-Ref discrepancy,Overall concordance from sample.q20_dp10_concordance.eval
		##Don't forget to add .libPaths("/target/gpfs2/gcc/tools/GATK-1.3-24-gc8b1c92/public/R") to your ~/.Rprofile
		Rscript ${toolDir}/scripts/extract_info_GATK_variantEval_V3.R \
		--in ${sample}.concordance.q20.dp10.eval \
		--step q20_dp10_concordance \
		--name ${externalSampleID} \
		--comp comp_immuno \
		--header >> ${sampleConcordanceFile}		
	fi
	if [ $build == "N/A" ]
	then
 		echo "ERROR: unsure which build was used. None of the probes we checked was found in the array file."
 	fi
 	if [ $build == "ERROR" ]
 	then
 		echo "ERROR: one of the probe in the array file has an unexpected position. Therefore, we are not able to tell which build was used." 
	fi
fi
