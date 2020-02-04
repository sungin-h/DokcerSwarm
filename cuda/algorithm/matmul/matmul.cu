#include <iostream>
#include <cuda.h>

#define DATA_TYPE float
#define NX 1024*8 // A = NX * NY
#define NY 1024*32 // B = NY * NZ
#define NZ 1024
#define GPU_DEVICE 0

using namespace std;

__global__ void MatMul(DATA_TYPE* A, DATA_TYPE* B, DATA_TYPE* Out){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;
	DATA_TYPE tmp=0;
	
	for(int i=0; i<NY; ++i){
		tmp += A[NY*idy+i] * B[i*NZ+idx];
	}
	Out[NX*idy + idx] = tmp;
	
}

void init_mat(DATA_TYPE* MAT, int size){
	for(int i=0; i<size; ++i){
		MAT[i]=1;
	}
}

void GPU_argv_init(){
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, GPU_DEVICE);
	cout<<"setting device "<< GPU_DEVICE << "with name" <<  deviceProp.name <<endl;
	cudaSetDevice( GPU_DEVICE);
}

int main(){

	int size_A = NX*NY*sizeof(DATA_TYPE);
	int size_B = NY*NZ*sizeof(DATA_TYPE);
	int size_C = NX*NZ*sizeof(DATA_TYPE);

	DATA_TYPE* hA = (DATA_TYPE*)malloc(size_A);
	DATA_TYPE* hB = (DATA_TYPE*)malloc(size_B);
	DATA_TYPE* hC = (DATA_TYPE*)malloc(size_C); // result of matrix multiplication

	init_mat(hA, NX*NY);
	init_mat(hB, NY*NZ);

	DATA_TYPE* dA;
	DATA_TYPE* dB;
	DATA_TYPE* dC;

	GPU_argv_init();

	cudaMalloc(&dA, size_A);
	cudaMalloc(&dB, size_B);
	cudaMalloc(&dC, size_C);

	cudaMemcpy(dA, hA, size_A, cudaMemcpyHostToDevice);
	cudaMemcpy(dB, hB, size_B, cudaMemcpyHostToDevice);

	dim3 block(32,8);
	dim3 grid(NY/block.x, 1);

	MatMul<<< block, grid >>>(dA,dB,dC);
	cudaDeviceSynchronize();


	cudaError_t err = cudaGetLastError();
	if (err != cudaSuccess) 
		cout<<"Error:"<< cudaGetErrorString(err) <<endl;

	cudaMemcpy(hC, dC, size_C, cudaMemcpyDeviceToHost);

	for(int i=0; i<10; ++i){
		cout<<hC[i];
		if((i%128) == 127){
			cout<<endl;
		}
	}
	cout<<endl;

	cudaFree(hA);
	cudaFree(hB);
	cudaFree(hC);

}

