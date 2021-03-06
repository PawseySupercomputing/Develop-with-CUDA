#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <cuda_runtime.h>
#include <cublas_v2.h>

// prints error if detected and exits 
void inline check(cudaError_t err, const char* filename, int line)
{
	if (err != cudaSuccess) 
	{ 
		printf("%s-l%i: %s\n", filename, line, cudaGetErrorString(err)); 
		exit(EXIT_FAILURE);
	}
}

// detects cublas non-sucess status and exits
void inline checkStatus(cublasStatus_t status, const char* filename, int line)
{
   if (status != CUBLAS_STATUS_SUCCESS)
  {
        printf("%s-l%i: cublas status %i\n", filename, line, status);
        exit(EXIT_FAILURE);
  }
}

// prints start and end of float array
void printArrayTerse(float* array, int length, int num)
{
	if (length<2*num) { num = length/2; }
	for (int i=0; i<num; i++)
	{
		printf("%.0f ",array[i]);
	}
	printf("... ");
    for (int i=length-num; i<length; i++)
    {
        printf("%.0f ",array[i]);
    }
    printf("\n");

}

// add two vectors
int main(int argc, char** argv)
{
	// variable declarations
	cudaError_t err;                 // variable for error codes
    cublasStatus_t status;           // variable for cublas status
    cublasHandle_t handle;           // variable for cublas handle
    int device;                      // current device id
    struct cudaDeviceProp prop;      // current device properties
	float* hostArrayA;                 // pointer for array A in host memory
    float* hostArrayB;                 // pointer for array B in host memory
	float* deviceArrayA;               // pointer for array A in device memory
    float* deviceArrayB;               // pointer for array B in device memory
	int length = 262144;             // length of array
    int size = length*sizeof(float);   // size of array in bytes

    // get device properties
    err = cudaGetDevice(&device);
    check(err, __FILE__, __LINE__);
    err = cudaGetDeviceProperties(&prop, device);
    check(err, __FILE__, __LINE__);
    printf("\nDevice properties: using %s\n\n",prop.name);

	// allocate host memory
	err = cudaHostAlloc((void**)&hostArrayA,size,cudaHostAllocDefault);
	check(err, __FILE__, __LINE__);
    err = cudaHostAlloc((void**)&hostArrayB,size,cudaHostAllocDefault);
    check(err, __FILE__, __LINE__);

	// allocate device memory
	err = cudaMalloc((void**)&deviceArrayA,size);
    check(err, __FILE__, __LINE__);
    err = cudaMalloc((void**)&deviceArrayB,size);
    check(err, __FILE__, __LINE__);

	// initialise host memory
	for(int i=0; i<length; i++)
	{
		hostArrayA[i] = i;
        hostArrayB[i] = 1;
	}

    // print host memory values for all arrays
	printf("Array A: ");
	printArrayTerse(hostArrayA,length,8);
    printf("Array B: ");
    printArrayTerse(hostArrayB,length,8);

	// prepare cuBLAS context
    status = cublasCreate(&handle);
    checkStatus(status,__FILE__,__LINE__);

	// copy host to device for arrays A and B
	status = cublasSetVector(length,sizeof(float),hostArrayA, 1, deviceArrayA, 1);
    checkStatus(status, __FILE__, __LINE__);
    // HINT: use cublasSetVector to copy array B to the device
    checkStatus(status, __FILE__, __LINE__);
    printf("\nCopied array A and B to device\n\n");

    // perform B = 1*A + B using cublas
	const float c = 1.0f;
    // HINT: use cublasSaxpy to at array A and B together
    checkStatus(status, __FILE__, __LINE__);
    printf("Performed B = A + B using cublas\n\n");

	// copy device to host for array B
	// HINT: use cublasGetVector copy array B back to the host
    checkStatus(status, __FILE__, __LINE__);
    printf("Copied array B from device\n\n");

    // destroy cuBLAS context
    status = cublasDestroy(handle);
    checkStatus(status,__FILE__,__LINE__);

	// print host memory values for array C
    printf("Array B: ");
    printArrayTerse(hostArrayB,length,8);

	// free device memory
    err = cudaFree(deviceArrayA);
    check(err, __FILE__, __LINE__);
    err = cudaFree(deviceArrayB);
    check(err, __FILE__, __LINE__);

	// free host memory
	err = cudaFreeHost(hostArrayA);
    check(err, __FILE__, __LINE__);
    err = cudaFreeHost(hostArrayB);
    check(err, __FILE__, __LINE__);
    printf("\nFreed device and host memory\n\n");

	// exit
	return EXIT_SUCCESS;
}
