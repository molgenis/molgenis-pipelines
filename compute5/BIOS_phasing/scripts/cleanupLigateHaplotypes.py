import glob
import shutil
import argparse

parser = argparse.ArgumentParser(description='Cleanup LigateHaplotypes.')
parser.add_argument('directory',help='directory that contains LigatedHaplotypes script to clean up')

args = parser.parse_args()

print('cleaning up:')
for job in glob.glob(args.directory+'/LigateHaplotypes_*.sh'):
    seen = []
    seen2 = []
    with open(job) as input_file, open(job+'.tmp','w') as out:
        for line in input_file:
            if line.startswith('chromosomeChunk'):
                if line.split('"')[1] in seen:
                    continue
                seen.append(line.split('"')[1])
            elif line.startswith('for chunk in'):
                new_line = []
                line = line.split('"')
                for i in line[1:-1]:
                    if i in seen2:
                        continue
                    seen2.append(i)
                    new_line.append(i)
                line = '"'.join(new_line)
            out.write(line)
            
    print(job+'.tmp -> '+job)
    shutil.move(job+'.tmp', job)
