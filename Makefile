abi = 1
rev = 3.0
KFVER = $(abi).$(rev)

doc:
	@echo "Start by reading the README file.  If you want to build and test lots of stuff, do a 'make testall'"
	@echo "but be aware that 'make testall' has dependencies that the basic kissfft software does not."
	@echo "It is generally unneeded to run these tests yourself, unless you plan on changing the inner workings"
	@echo "of kissfft and would like to make use of its regression tests."

testall:
	# The simd and int32_t types may or may not work on your machine 
	make -C test DATATYPE=simd CFLAGADD="$(CFLAGADD)" test
	make -C test DATATYPE=int32_t CFLAGADD="$(CFLAGADD)" test
	make -C test DATATYPE=int16_t CFLAGADD="$(CFLAGADD)" test
	make -C test DATATYPE=float CFLAGADD="$(CFLAGADD)" test
	make -C test DATATYPE=double CFLAGADD="$(CFLAGADD)" test
	echo "all tests passed"

tarball: clean
	hg archive -r v$(KFVER) -t tgz kiss_fft$(KFVER).tar.gz 
	hg archive -r v$(KFVER) -t zip kiss_fft$(KFVER).zip

asm: kiss_fft.s

kiss_fft.s: kiss_fft.c kiss_fft.h _kiss_fft_guts.h
	[ -e kiss_fft.s ] && mv kiss_fft.s kiss_fft.s~ || true
	gcc -S kiss_fft.c -O3 -mtune=native -ffast-math -fomit-frame-pointer -unroll-loops -dA -fverbose-asm 
	gcc -o kiss_fft_short.s -S kiss_fft.c -O3 -mtune=native -ffast-math -fomit-frame-pointer -dA -fverbose-asm -DFIXED_POINT
	[ -e kiss_fft.s~ ] && diff kiss_fft.s~ kiss_fft.s || true

clean:
	cd test && make clean
	cd tools && make clean
	rm -f kiss_fft*.tar.gz *~ *.pyc kiss_fft*.zip
	rm -f kiss_fft.1.3.0.dylib /usr/local/lib/kiss_fft.dylib
	rm -f shared/*

## Shared Library Construction
name=kiss_fft
# Set PREFIX to installation prefix
PREFIX = /usr
ifeq ($(shell uname -s), Darwin)
        lib_so = $(name).$(KFVER).dylib
	linkname = $(name).dylib
        sharedopt = -dynamiclib
        sharedv = -current_version $(KFVER)
        copts = -I/usr/include/malloc
else
        soname = $(name).so.$(abi)
        lib_so = $(soname).$(rev)
        linkname = $(name).so
        sharedopt = -shared -Wl,-soname,$(soname)
	copts = -fPIC
endif

shared/kiss_fft.o: kiss_fft.c 
	gcc $(copts) -c  kiss_fft.c -o shared/kiss_fft.o

shared/kiss_fftr.o: tools/kiss_fftr.c
	gcc $(copts) -I. -c tools/kiss_fftr.c -o shared/kiss_fftr.o

shared/$(lib_so): shared/kiss_fft.o shared/kiss_fftr.o
	gcc $(sharedopt) -o $@ $^ $(LDFLAGS) $(sharedv)

shared: shared/$(lib_so)

install: shared/$(lib_so)
	mv shared/$(lib_so) $(PREFIX)/lib
	ln -sf shared/$(lib_so) $(PREFIX)/$(linkname)
	cp kiss_fft.h $(PREFIX)/include
	cp tools/kiss_fftr.h $(PREFIX)/include

