












#Load plink
module load PLINK/1.07-x86_64

#Created PED/MAP files
plink \
--noweb \
--file ./$BUILD/$BASE \
--out ./$BUILD/$BASE \
--recode \
--make-bed

