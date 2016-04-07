#MOLGENIS walltime=01:00:00 nodes=1 ppn=4 mem=6gb

#string sampleConcordanceFile
#string tmpName
#string sampleNameID
#string externalSampleID
#string familyList
#string arrayMapFile
#string tempDir
#string intermediateDir
#string dedupBam
#string indexFile
#string dbSNPExSiteAfter129Vcf
#string sequenomReport
#string sequenomInfo
#string gatkJar
#string gatkVersion
#string	project
#string logsDir
#string ngsUtilsVersion

sleep 5
#
## Default using build 37
#
build="build37"

module load ${ngsUtilsVersion}
module load ${gatkVersion}

if test ! -e ${sequenomReport};
then
	echo "name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance" > ${sampleConcordanceFile}
	echo "[1] NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA" >> ${sampleConcordanceFile} 
else
	#########################################################################
	#########################################################################
	#########################################################################

	grep ${externalSampleID} ${sequenomReport} > ${intermediateDir}/${externalSampleID}_sequenomReport.txt.tmp
	grep -v -P '\tNA\t' ${intermediateDir}/${externalSampleID}_sequenomReport.txt.tmp > ${intermediateDir}/${externalSampleID}_sequenomReport.txt.filtered

	##Push sample belonging to family "1" into list.txt
	echo '1 ${externalSampleID}' > ${familyList}

        echo "" > ${intermediateDir}/${externalSampleID}.concordance.tmp.map

        for i in $(cat ${intermediateDir}/${externalSampleID}_sequenomReport.txt.filtered | awk -F"\t" '{print $2}')
        do
	VALUE=$( grep $i ${sequenomInfo} )
                COLS=( $VALUE );
                RS1="${COLS[0]}"
                CHR="${COLS[3]}"
                START="${COLS[4]}"
                STOP="${COLS[5]}"

                echo -e "${CHR}\t${RS1}\t"0"\t${START}"| sort -k1n -k4n | uniq >> ${intermediateDir}/${externalSampleID}.concordance.tmp.map
        done


        ##Create .fam, .lgen and .map file from sample_report.txt
        sed -e '1,8d' ${intermediateDir}/${externalSampleID}_sequenomReport.txt.filtered | awk -F"\t" '{print "1",$5,"0","0","0","1"}' | uniq > ${intermediateDir}/${externalSampleID}.concordance.fam


	cat ${intermediateDir}/${externalSampleID}_sequenomReport.txt.filtered | awk -F"\t" '{
        if (length($3) =="1")
                print "1",$5,$2,$3,$3
        else
	 print "1",$5,$2,substr($3, 1, 1),substr($3, 2, 1)
        }' | awk -f /gcc/tools/scripts/RecodeFRToZero.awk > ${intermediateDir}/${externalSampleID}.concordance.lgen


	grep -P '^[123456789]' ${intermediateDir}/${externalSampleID}.concordance.tmp.map | sort -k1n -k4n > ${intermediateDir}/${externalSampleID}.concordance.map
        grep -P '^[X]\s' ${intermediateDir}/${externalSampleID}.concordance.tmp.map | sort -k4n >> ${intermediateDir}/${externalSampleID}.concordance.map
        grep -P '^[Y]\s' ${intermediateDir}/${externalSampleID}.concordance.tmp.map | sort -k4n >> ${intermediateDir}/${externalSampleID}.concordance.map


	module load plink/1.07-x86_64
	module list
	
	plink \
	--lfile ${sampleNameID}.concordance \
	--recode \
	--noweb \
	--out ${sampleNameID}.concordance \
	--keep ${familyList}
	
	module unload plink
	module load plink/1.08
	module list
	
	##Create genotype VCF for sample
	plink108 \
	--recode-vcf \
	--ped ${sampleNameID}.concordance.ped \
	--map ${arrayMapFile} \
	--out ${sampleNameID}.concordance
	
	##Rename plink.vcf to sample.vcf
	mv ${sampleNameID}.concordance.vcf ${sampleNameID}.genotypeArray.vcf
	
	##Replace chr23 and 24 with X and Y
    perl -pi -e 's/^23/X/' ${sampleNameID}.genotypeArray.vcf
    perl -pi -e 's/^24/Y/' ${sampleNameID}.genotypeArray.vcf
	
	##Remove family ID from sample in header genotype VCF
	perl -pi -e 's/1_${externalSampleID}/${externalSampleID}/' ${sampleNameID}.genotypeArray.vcf
	
	##Create binary ped (.bed) and make tab-delimited .fasta file for all genotypes
	sed -e 's/chr//' ${sampleNameID}.genotypeArray.vcf | awk '{OFS="\t"; if (!/^#/){print $1,$2-1,$2}}' \
	> ${sampleNameID}.genotypeArray.bed
	
if [ "${build}" == "build37" ]
then
		###################################
	#Sequonomfile is on build 37

	echo "Using build: {$build}"	

		module load BEDTools/Version-2.11.2
		module list
		
		##Create tabular fasta from bed
		fastaFromBed \
		-fi ${indexFile} \
		-bed ${sampleNameID}.genotypeArray.bed \
		-fo ${sampleNameID}.genotypeArray.fasta -tab
		
		##Align vcf to reference AND DO NOT FLIP STRANDS!!! (genotype data is already in forward-forward format) If flipping is needed use "-f" command before sample.genotype_array.vcf
		align-vcf-to-ref.pl -f \
		${sampleNameID}.genotypeArray.vcf \
		${sampleNameID}.genotypeArray.fasta \
		${sampleNameID}.genotypeArray.aligned_to_ref.vcf \
		> ${sampleNameID}.genotypeArray.aligned_to_ref.vcf.out
	
		##Some GATK versions sort header alphabetically, which results in wrong individual genotypes. So cut header from "original" sample.genotype_array.vcf and replace in sample.genotype_array.aligned_to_ref.lifted_over.out
		head -3 ${sampleNameID}.genotypeArray.vcf > ${sampleNameID}.genotypeArray.header.txt
	
		sed '1,3d' ${sampleNameID}.genotypeArray.aligned_to_ref.vcf \
		> ${sampleNameID}.genotypeArray.headerless.vcf
	
		cat ${sampleNameID}.genotypeArray.header.txt \
		${sampleNameID}.genotypeArray.headerless.vcf \
		> ${sampleNameID}.genotypeArray.updated.header.vcf
	
		##Create interval_list of CHIP SNPs to call SNPs in sequence data on
		iChip_pos_to_interval_list.pl \
		${sampleNameID}.genotypeArray.updated.header.vcf \
		${sampleNameID}.genotypeArray.updated.header.interval_list
	
		module unload GATK
		module load 1.2-1-g33967a4
		module list
	
		###THESE STEPS USE NEWER VERSION OF GATK THAN OTHER STEPS IN ANALYSIS PIPELINE!!!
		##Call SNPs on all positions known to be on array and output VCF (including hom ref calls)
		java -Xmx4g -jar ${EBROOTGATK}/${gatkJar} \
		-l INFO \
		-T UnifiedGenotyper \
		-R ${indexFile} \
		-I ${dedupBam} \
		-o ${sampleNameID}.concordance.allSites.vcf \
		-stand_call_conf 30.0 \
		-stand_emit_conf 10.0 \
		-out_mode EMIT_ALL_SITES \
		-L ${sampleNameID}.genotypeArray.updated.header.interval_list
	
		##Change FILTER column from GATK "called SNPs". All SNPs having Q20 & DP10 change to "PASS", all other SNPs are "filtered" (not used in concordance check)
		change_vcf_filter.pl \
		${sampleNameID}.concordance.allSites.vcf \
		${sampleNameID}.concordance.q20.dp10.vcf 10 20
	
		##Calculate condordance between genotype SNPs and GATK "called SNPs"
		java -Xmx2g -Djava.io.tmpdir=${tempDir} -jar ${EBROOTGATK}/${gatkJar} \
		-T VariantEval \
		-eval:eval,VCF ${sampleNameID}.concordance.q20.dp10.vcf \
		-comp:comp_immuno,VCF ${sampleNameID}.genotypeArray.updated.header.vcf \
		-o ${sampleNameID}.concordance.q20.dp10.eval \
		-R ${indexFile} \
		-D:dbSNP,VCF ${dbSNPExSiteAfter129Vcf} \
		-EV GenotypeConcordance
	
		##Create concordance output file with header
		echo 'name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance' \
		> ${sampleConcordanceFile}
	
		module unload GATK
		module load 1.3-24-gc8b1c92
		module list
		
		##Retrieve name,step,#SNPs,%dbSNP,Ti/Tv known,Ti/Tv Novel,Non-Ref Sensitivity,Non-Ref discrepancy,Overall concordance from sample.q20_dp10_concordance.eval
		##Don't forget to add .libPaths("/target/gpfs2/gcc/tools/GATK-1.3-24-gc8b1c92/public/R") to your ~/.Rprofile
		extract_info_GATK_variantEval_V3.R \
		--in ${sampleNameID}.concordance.q20.dp10.eval \
		--step q20_dp10_concordance \
		--name ${externalSampleID} \
		--comp comp_immuno \
		--header >> ${sampleConcordanceFile}		
	fi
	if [ "${build}" == "N/A" ]
	then
 		echo "ERROR: unsure which build was used. None of the probes we checked was found in the array file."
 	fi
 	if [ "${build}" == "ERROR" ]
 	then
 		echo "ERROR: one of the probe in the array file has an unexpected position. Therefore, we are not able to tell which build was used." 
	fi
fi

