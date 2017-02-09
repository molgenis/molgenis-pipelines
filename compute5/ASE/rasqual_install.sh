
set -e
set -x

# change this to current version number on github
VERSION="a0e84aa"

# get latest rasqual version (if you want older verison download the .zip from github archive)
rm -rf rasqual
rm -rf rasqual_$VERSION
git clone https://github.com/dg13/rasqual.git
mv -f rasqual/ rasqual_$VERSION

# install CLAPACK
if [ ! -d CLAPACK-3.2.1 ];
then
  wget http://www.netlib.org/clapack/clapack.tgz
  tar zxvf clapack.tgz
fi

cd CLAPACK-3.2.1
CLAPACKPATH=$(pwd)

if [ ! -f make.inc ]
then 
  mv make.inc.example make.inc
fi

make f2clib
# make BLAS (For me its says nothing to be done but did anyway)
make
if [ ! -f liblapack.a ]
then
  ln -s lapack_LINUX.a liblapack.a
fi
if [ ! -f libtmglib.a ]
then
  ln -s tmglib_LINUX.a libtmglib.a
fi
if [ ! -f libblas.a ]
then
  ln -s blas_LINUX.a libblas.a
fi
cd ../

# if GSL is not installed, install it first. Should be already present through easybuild tho
module load GSL/2.1-foss-2015b 


# export correct flags
export CFLAGS="-I${CLAPACKPATH}/INCLUDE -I${CLAPACKPATH}F2CLIBS"
export LDFLAGS="-L${CLAPACKPATH} -L${CLAPACKPATH}/F2CLIBS"

# make rasqual
cd rasqual_$VERSION/src/
sed -i 's;/usr/include/gsl;${EBROOTGSL}/lib/;' Makefile

make
make install

cd ASVCF
make

cd ../..

# test
module load tabix
tabix data/chr11.gz 11:2315000-2340000 | bin/rasqual -y data/Y.bin -k data/K.bin -n 24 -j 2 -l 409 -m 61 \
   -s 2323227,2323938,2324640,2325337,2328175,2329966,2330551,2331219,2334884,2335715,2338574,2339093 \
   -e 2323452,2324188,2324711,2325434,2328220,2330040,2330740,2331248,2334985,2337897,2338755,2339430 \
   -t -f TSPAN32 -z
tabix data/chr11.gz 11:2315000-2340000 | bin/rasqual -y data/Y.bin -k data/K.bin -n 24 -j 1 -l 409 -m 63 \
   -s 2316875,2320655,2321750,2321914,2324112 -e 2319151,2320937,2321843,2323290,2324279 \
   -t -f C11orf21 -z
