#include <iostream>



#define ASYNC_FACTOR 2
#define SIZE 1024*1024*4
//#define STREAM_FLAG cudaStreamDefault
//define STREAM_FLAG cudaStreamNonBlocking

void GPU_argv_init(int dev_num){
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, dev_num);
	cudaSetDevice( dev_num );

}
__global__ void mykernel(float* input, int len){
	
}

int main(){

	float* host_arr;
	float* host_pinned;

	float* dev_arr;

	GPU_argv_init(0);
	host_arr = (float*)malloc(SIZE*ASYNC_FACTOR);
	cudaMallocHost(&host_pinned, SIZE*ASYNC_FACTOR); //page-locked host memory
	cudaHostRegister(host_arr, SIZE*ASYNC_FACTOR, cudaHostRegisterPortable);
	cudaMalloc(&dev_arr, SIZE*ASYNC_FACTOR);

	cudaStream_t stream[ASYNC_FACTOR];
	for(int i=0; i<ASYNC_FACTOR; ++i){
		cudaStreamCreate(&stream[i]);	
		//cudaStreamCreateWithPriority(&stream[i],STREAM_FLAG ,i); //lower priority number represent high priority
	}

	for(int i=0; i<ASYNC_FACTOR; ++i){
		cudaMemcpyAsync(dev_arr+i*SIZE, host_pinned, SIZE, cudaMemcpyHostToDevice, stream[i]);
		mykernel<<<128,32,0,stream[i]>>>(dev_arr+i*SIZE, len);
		cudaDeviceSynchronize();
		cudaMemcpyAsync(host_arr+i*SIZE, dev_arr+i*SIZE, SIZE, cudaMemcpyDeviceToHost, stream[i]);
	}

	if( cudaStreamQuery(stream[0]) == cudaSuccess){
		//stream[0] has been complete
	}

	for(int i=0; i<ASYNC_FACTOR; ++i){
		cudaStreamSynchronize(stream[i]);
		cudaStreamDestroy(stream[i]);
	}


	return 0;
}
