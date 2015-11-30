#MOLGENIS walltime=23:59:00 mem=6gb ppn=6

#string	intermediateDir
#string	externalSampleID
#string	controlGroupRds
#string	inputDataRawSample
#string rVersion
#string apriori13
#string apriori18
#string apriori21
#string resultsDir
#string reportRMD
#string qcReportRMD
#string reportHTML
#string qcReportHTML
#string reportPDF
#string qcReportPDF
#string wkHtmlToPdfVersion

if [ ! -f $intermediateDir ]
then
    	mkdir -p $intermediateDir
fi

if [ ! -f $resultsDir ]
then
	mkdir -p $resultsDir
fi

module load R
module load ngs-utils
module load PPVforNIPT
module load wkhtmltopdf/${wkHtmlToPdfVersion}

Rmarkdownfile_Diagnostic_output_table="${EBROOTNGSMINUTILS}/${reportRMD}"
Rmarkdownfile_QC="${EBROOTNGSMINUTILS}/${qcReportRMD}"

echo "started"
Rscript ${EBROOTNGSMINUTILS}/NIPT_Diagnostics_v3.0.R $intermediateDir $externalSampleID $controlGroupRds $inputDataRawSample $Rmarkdownfile_Diagnostic_output_table $Rmarkdownfile_QC $apriori13 $apriori18 $apriori21 $reportHTML $qcReportHTML

$EBROOTWKHTMLTOPDF/wkhtmltopdf-amd64 --page-size A4 $reportHTML $reportPDF
$EBROOTWKHTMLTOPDF/wkhtmltopdf-amd64 --page-size A4 $qcReportHTML $qcReportPDF
