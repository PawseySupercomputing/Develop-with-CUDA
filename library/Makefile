.PHONY = default clean

default: library.cu
	nvcc -o library library.cu -lcublas

clean : library
	rm -f library library.txt slurm*.out
