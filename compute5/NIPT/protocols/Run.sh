#MOLGENIS walltime=23:59:00 mem=36gb ppn=6

#string	intermediateDir
#string	externalSampleID
#string	controlGroupRds
#string	inputDataRawSample
#string rVersion
#string apriori13
#string apriori18
#string apriori21
#string reportRMD
#string qcReportRMD
#string reportHTML
#string qcReportHTML
#string reportPDF
#string qcReportPDF
#string wkHtmlToPdfVersion
umask 0007

if [ ! -f $intermediateDir ]
then
    mkdir -m 770 -p $intermediateDir
fi

module load R/${rVersion}
module load ngs-utils/${ngsUtilsVersion}
module load PPVforNIPT/${ppvForNiptVersion}
module load wkhtmltopdf/${wkHtmlToPdfVersion}
module list

Rmarkdownfile_Diagnostic_output_table="${EBROOTNGSMINUTILS}/${reportRMD}"
Rmarkdownfile_QC="${EBROOTNGSMINUTILS}/${qcReportRMD}"

echo "started"
Rscript ${EBROOTNGSMINUTILS}/NIPT_Diagnostics_v3.0.R $intermediateDir $externalSampleID $controlGroupRds $inputDataRawSample $Rmarkdownfile_Diagnostic_output_table $Rmarkdownfile_QC $apriori13 $apriori18 $apriori21 $reportHTML $qcReportHTML

$EBROOTWKHTMLTOPDF/wkhtmltopdf-amd64 --page-size A4 $reportHTML $reportPDF
$EBROOTWKHTMLTOPDF/wkhtmltopdf-amd64 --page-size A4 $qcReportHTML $qcReportPDF
