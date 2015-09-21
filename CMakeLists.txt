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
  PRIVATE tools
  PRIVATE .)

install(TARGETS kiss_fft
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib)

install(
  FILES kiss_fft.h kfc.h kiss_fftnd.h kiss_fftndr.h kiss_fftr.h
  DESTINATION include)
