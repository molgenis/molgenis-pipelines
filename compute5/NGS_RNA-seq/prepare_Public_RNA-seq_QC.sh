module load Molgenis-Compute/v15.04.1-Java-1.7.0_80
sh molgenis_compute.sh \
  --backend slurm \
  --generate \
  --header /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/header.ftl \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_QC/parameters.converted.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/samplesheets/$1 \
  -w /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_QC/workflow.csv \
  -rundir /groups/umcg-wijmenga/tmp04/umcg-ndeklein/rundirs/$2 --weave

