#include <iostream>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <mma.h>

#define N 1024*1024*256

#define TB 256
#define ITER 1024*2
#define GRID 512


__global__ void double_precision(float* A, float* B, float* C){
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	for(int i=0; i<ITER; ++i){
		C[i*TB*GRID + tid] = A[i*TB*GRID + tid] * B[i*TB*GRID + tid];
	}
}

__global__ void low_precision(int4*  A, int4* B, int4* C){
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	for(int i=0; i<ITER; ++i){
		reinterpret_cast<int4*>(C)[i*TB*GRID + tid] = reinterpret_cast<int4*>(A)[i*TB*GRID + tid] + reinterpret_cast<int4*>(B)[i*TB*GRID + tid];
	}
}

int main(){
	float* host_A;
	float* host_B;
	float* host_C;
	float* dev_A;
	float* dev_B;
	float* dev_C;

	cudaSetDevice(0);

	host_A = (float*)malloc(N*4);
	host_B = (float*)malloc(N*4);
	host_C = (float*)malloc(N*4);

	for(int i=0; i<N; ++i){
		host_A[i] = 1.0;
		host_B[i] = 2.0;
	}

	cudaMalloc(&dev_A, N*4);
	cudaMalloc(&dev_B, N*4);
	cudaMalloc(&dev_C, N*4);

	cudaMemcpy(dev_A, host_A, N*4, cudaMemcpyHostToDevice);
	cudaMemcpy(dev_B, host_B, N*4, cudaMemcpyHostToDevice);

	double_precision<<<TB,GRID>>>(dev_A,dev_B,dev_C);
	cudaDeviceSynchronize();
	
	cudaFree(dev_A);
	cudaFree(dev_B);
	cudaFree(dev_C);
	free(host_A);
	free(host_B);
	free(host_C);

	return 0;
}
