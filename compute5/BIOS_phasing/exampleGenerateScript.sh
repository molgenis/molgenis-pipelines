module load Molgenis-Compute/v16.05.1-Java-1.8.0_45
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
  --backend slurm \
  --generate \
  --header templates/slurm/header.ftl \
  -p parameters.converted.csv \
  -p samplesheet.csv \
  -w workflow.csv \
  -p CHRs_X_Y.csv \
  -p CHR_chunks.txt \
  -rundir jobs/ --weave
