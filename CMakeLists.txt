cmake_minimum_required(VERSION 3.0)

project(KissFFT VERSION 1.3.0)

add_library(kiss_fft SHARED
  # main FFT implementation
  kiss_fft.c
  # from the tools/ directory
  tools/fftutil.c 
  tools/kfc.c 
  tools/kiss_fastfir.c 
  tools/kiss_fftnd.c 
  tools/kiss_fftndr.c 
  tools/kiss_fftr.c
  )
target_include_directories(kiss_fft
  PRIVATE .
  PRIVATE tools)

install(TARGETS kiss_fft
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib)

install(
  FILES kiss_fft.h tools/kfc.h tools/kiss_fftnd.h tools/kiss_fftndr.h tools/kiss_fftr.h
  DESTINATION include)
