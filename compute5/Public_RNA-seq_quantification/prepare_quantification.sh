module load Molgenis-Compute/v19.01.1-Java-11-LTS
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
  --backend slurm \
  --generate \
  -p parameter_files/parameters.converted.csv \
  -p samplesheet.csv \
  -w workflows/workflow.csv \
  -rundir results/ \
  --weave

