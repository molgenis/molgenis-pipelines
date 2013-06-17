#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=08:00:00 nodes=1 cores=1 mem=1
#TARGETS

module load fastqc/${fastqcVersion}

<#if seqType == "SR">
     getFile ${srbarcodefqgz}
	 alloutputsexist \
	 "${leftfastqczip}" \
	 "${leftfastqcsummarytxt}" \
	 "${leftfastqcsummarylog}" \
<#else>
    getFile "${leftbarcodefqgz}"
    getFile "${rightbarcodefqgz}"
	alloutputsexist \
	 "${leftfastqczip}" \
	 "${leftfastqcsummarytxt}" \
	 "${leftfastqcsummarylog}" \
	 "${rightfastqczip}" \
	 "${rightfastqcsummarytxt}" \
	 "${rightfastqcsummarylog}"
</#if>

# first make logdir...
mkdir -p "${intermediatedir}"

# pair1
fastqc ${leftbarcodefqgz} \
-Djava.io.tmpdir=${tempdir} \
-Dfastqc.output_dir=${intermediatedir} \
-Dfastqc.unzip=false

<#if seqType == "PE">
# pair2
fastqc ${rightbarcodefqgz} \
-Djava.io.tmpdir=${tempdir} \
-Dfastqc.output_dir=${intermediatedir} \
-Dfastqc.unzip=false
</#if>

<#if seqType == "SR">
      putFile ${leftfastqczip}
      putFile ${leftfastqcsummarytxt}
      putFile ${leftfastqcsummarylog}
<#else>
      putFile ${leftfastqczip}
      putFile ${leftfastqcsummarytxt}
      putFile ${leftfastqcsummarylog}
      putFile ${rightfastqczip}
      putFile ${rightfastqcsummarytxt}
      putFile ${rightfastqcsummarylog}
</#if>