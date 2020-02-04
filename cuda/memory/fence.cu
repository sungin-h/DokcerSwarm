#include <iostream>
#include <cuda.h>
#include <cuda_runtime_api.h>

__device__ volatile int X=1, Y=2;


__global__ kernel(){

	writeXY();
	readXY();
	//__threadfence_block(); // All writes to all memory and all reads from all memory made by the calling thread before the call to __threadfence_block()
	//__threadfence(); // no writes after the call to __threadfence();
	//__threadfence_system(); // acts as __threadfence_block() for all threads in the block are observed by all threads in the device, host threads, and all threads in peer devices

}
__device__ writeXY(){
	X=10;
	Y=20;
}
__device__ readXY(){
	int A=X;
	int B=Y;
}


int main(){


	return 0;
}
