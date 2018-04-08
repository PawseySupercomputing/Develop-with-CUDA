.PHONY = default clean

default: query.cu
	nvcc -o query query.cu

clean : 
	rm -f query query.txt slurm-*.out
