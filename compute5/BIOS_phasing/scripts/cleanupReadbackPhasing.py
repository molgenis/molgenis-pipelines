import glob
import shutil

parser = argparse.ArgumentParser(description='Cleanup ReadbackPhasing scripts.')
parser.add_argument('directory',help='directory that contains ReadbackPhaser scripts script to clean up')

args = parser.parse_args()

seen = []
for job in glob.glob(args.directory+'/ReadbackedPhasing_*.sh'):
    with open(job) as input_file, open(job+'.tmp','w') as out:
        for line in input_file:
            if line.startswith('bam'):
                if line.split('"')[1] in seen:
                    continue
                seen.append(line.split('"')[1])
            elif line.startswith('for chunk in'):
                line = line.split('"')
                out.write(
            out.write(line)
            
    print(job+'.tmp -> '+job)
    shutil.move(job+'.tmp', job)
