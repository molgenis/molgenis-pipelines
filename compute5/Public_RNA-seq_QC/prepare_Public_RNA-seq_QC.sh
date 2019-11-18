# if Molgenis-Compute is installed using EasyBuild, otherwise point to the full path
module load Molgenis-Compute/v19.01.1-Java-11-LTS
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
  --backend slurm \
  --generate \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_QC/parameters.converted.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/samplesheets/samplesheet.csv \
  -w /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_QC/workflow.csv \
  -rundir /groups/umcg-wijmenga/tmp04/umcg-ndeklein/rundirs/QC/ --weave

