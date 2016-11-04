chunks = 5000000
overlap = 500000
interval_list_location = '/apps/data/ftp.broadinstitute.org/bundle/2.8/b37/human_g1k_v37.chr'
with open('chromosome_chunks.txt','w') as out:
    out.write('chromosomeChunk\n')
    for chr in range(1,26,1):
        with open(interval_list_location+str(chr)+'.interval_list') as interval_list:
            for line in interval_list:
                if not line.startswith('@'):
                    line = line.strip().split('\t')
                    chr = line[0]
                    start = int(line[1])
                    end_of_chr = int(line[2])
                    end = chunks+overlap
                    while end+chunks < end_of_chr:
                        new_start = start-overlap
                        if new_start < 0:
                            new_start = 1
                        out.write(chr+':'+str(new_start)+'-'+str(end)+'\n')
                        start += chunks
                        end+=chunks
                    out.write(chr+':'+str(start)+'-'+str(end_of_chr)+'\n')
