module load Molgenis-Compute/v16.05.1-Java-1.8.0_45
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
  --backend slurm \
  --generate \
  --header /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/header.ftl \
  -p ../parameters/parameters_quantification_stranded_reverse_complement.converted.csv \
  -p ../samplesheets/samplesheet_QC_reverse_complement.csv \
  -w ~/molgenis-pipelines/compute5/Public_RNA-seq_quantification/workflowHtseq.csv \
  -rundir ../rundirs/quantification_reverse_complement/ --weave 

