if [ "TEST$1" == "TEST" ]
then
   version=7.1.3
else
   version=$1
fi

root=`pwd`

tinkertar=tinker-${version}.tar.gz
url=http://dasher.wustl.edu/tinker/downloads
tinkerpdf=$root/TinkerLicence.pdf

if [ -e $tinkerpdf ] && [ -x $root/bin/minimize ]
then
    echo ""
    echo "*** Tinker appears to be built already - not rebuilding ***"
    echo "To force rebuilding, remove bin $root/bin/minimize or"
    echo "$root/$tinkerpdf"
    echo ""
fi

if [ ! -f $tinkertar ]
then
    wget --no-check-certificate ${url}/$tinkertar
fi

if [ ! -f $tinkerpdf ]
then
    wget --no-check-certificate -O ${tinkerpdf} ${url}/license.pdf
fi

echo " "
echo "*** Building Tinker V$version - this will take a while! ***"
echo " "

tar zxvf tinker-${version}.tar.gz

# Build FFT library
cd $root/tinker/fftw
export CC=gcc
export F77=gfortran
./configure --prefix=$root/tinker/fftwinst  --enable-threads
make; make install

# Create links for Tinker compilation
cd $root/tinker/source
ln -s ../linux/gfortran/*.make .
ln -s ../fftwinst/lib/libfftw3.a .
ln -s ../fftwinst/lib/libfftw3_threads.a .

# Remove kmp calls if not using Intel Fortran
cp initial.f initial.f.orig
sed 's/\!\$/c/g' initial.f.orig > initial.f

# Compile Tinker
echo ""
echo ""
echo "*** Running main compile ***"
source ./compile.make

echo "*** Running library compile ***"
source ./library.make
echo "done"

echo "*** Linking executables ***"
source ./link.make

echo "*** Renaming files ***"
mkdir -p ../bin
source ./rename.make

echo "*** Tinker installation complete ***"

