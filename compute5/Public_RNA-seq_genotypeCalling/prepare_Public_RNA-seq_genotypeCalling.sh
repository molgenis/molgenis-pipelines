module load Molgenis-Compute/v15.04.1-Java-1.7.0_80
molgenis_compute.sh --backend slurm \
  --footer /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/footer.ftl \
  --generate --header /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/header.ftl \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/chromosomes.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/parameters.converted.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/samplesheets/$1 \
  -w /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/workflowGenotypeCalling_first_part.csv \
  -rundir /groups/umcg-wijmenga/tmp04/umcg-ndeklein/rundirs/$2 --weave \
  -batch sampleName=200 | tee /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/batches.tmp

echo 'batches' > /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/batches.txt
grep -oP 'batch[0-9]*' /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/batches.tmp | uniq >> /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/batches.txt


molgenis_compute.sh --backend slurm \
  --footer /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/footer.ftl \
  --generate --header /groups/umcg-wijmenga/tmp04/umcg-ndeklein/templates/slurm/header.ftl \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/chromosomes.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/parameters.converted.csv \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/samplesheets/$1 \
  -p /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/batches.txt \
  -w /groups/umcg-wijmenga/tmp04/umcg-ndeklein/molgenis-pipelines/compute5/Public_RNA-seq_genotypeCalling/workflowGenotypeCalling_second_part.csv \
  -rundir /groups/umcg-wijmenga/tmp04/umcg-ndeklein/rundirs/$2 --weave 
