module load Molgenis-Compute/v16.05.1-Java-1.8.0_45
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
  --backend slurm \
  --generate \
  -p parameter_files/parameters.converted.csv \
  -p samplesheet.csv \
  -w workflows/workflow.csv \
  -rundir results/ \
  --weave

