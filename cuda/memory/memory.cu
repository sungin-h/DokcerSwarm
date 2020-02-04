#include <iostream>
#include <cuda.h>

#define SIZE 1024*1024*4
#define HOST_ALLOC_FLAG cudaHostAllocDefault // cudaMallocHost();
//#define HOST_ALLOC_FLAG cudaHostAllocPortable // pinned memory by all CUDA context
//#define HOST_ALLOC_FLAG cudaHostAllocMapped // Maps the allocation into the CUDA address space
//#define HOST_ALLOC_FLAG cudaHostAllocWriteCombined // WC memory can be transferred across PCI Express bus, but cannot read efficiently by most CPUs. WC memory is a good option for buffers that will be written by CPU and read by the device
#define MALLOC_MANAGED_FLAG cudaMemAttachGlobal // default
//#define MALLOC_MANAGED_FLAG cudaMemAttachHost // Devices, has zero value for the device attribute cudaDevAttrConcurrentManagedAccess, can not access the memory.
#define HOST_REGISTER_FLAG cudaHostRegisterDefault // mapped and protable
//#define HOST_REGISTER_FLAG cudaHostRegisterPortable // pinned memory by all CUDA context
//#define HOST_REGISTER_FLAG cudaHostRegisterMapped // maps the allocation into the CUDA addressspace
//#define HOST_REGISTER_FLAG cudaHostRegisterIoMemory // pointing to some memory-mapped I/O space, belonging to a third-party PCIe device
#define ADVICE cudaMemAdviseSetReadMostly // implies the data is mostly goint to be read and only occasionally written to. Any read accesses from any processor to this region will create a read-only copy
#define ADVICE cudaMemAdviseUnsetReadMostly // undoes setReadMostly
//#define ADVICE cudaMemAdviseSetPrefferedLocation // sets the preferred location
//#define ADVICE cudaMemAdviseUnsetPrefferedLocation // unset the prefered location
//#define ADVICE cudaMemAdviseSetAccessedBy // implies the data will be accessed by device
//#define ADVICE cudaMemAdviseUnsetAccessedBy // undoes the SetAccessedBy



extern __shared__ float shared[]; // dynamic shared memory
								  // kernel<<< blocks, grid, shm_amount>> ...
__device__ __managed__ int var[2]; 

__global__ shm_foo(){

	__shared__ float shm_arr[10]; // static allocated shared memory

	float* shm_arr0 = (float*)shared; 
	int* shm_arr1 = (float*)&shm_arr0[128]; 
	var[0]=1;
	var[1]=2;

}

void GPU_argv_init(int dev_num){
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, dev_num);
	cudaSetDevice( dev_num);
}

int main(){

	float* host_malloc;
	float* host_pinned;
	float* uvm_managed;
	float* pitched;
	float* dev_malloc;
	float* dev2_malloc;

	GPU_argv_init(0);

	/* allocate and register memory */
	host_malloc = (float*)malloc(SIZE);
	cudaHostAlloc(host_pinned, SIZE, HOST_ALLOC_FLAG); //page-locked host memory
	cudaMallocManaged(uvm_managed, SIZE, MALLOC_MANAGED_FLAG); //uvm memory
	cudaHostRegister(host_malloc, SIZE, HOST_REGISTER_FLAG); //map or pin the host memory
	cudaHostUnregister(host_malloc);	//unregisters a memory range
	cudaMallocPitch(pitched, SIZE, 4096, 4096); // may pad the allocation to meet the alignment requirements
	cudaMalloc(dev_malloc, SIZE); //malloc device global memory

	GPU_argv_init(1);
	cudaMalloc(dev2_malloc,SIZE);
	GPU_argv_init(0);

	/* other CUDA memory runtime APIs */
	cudaMemAdvise(uvm_managed, SIZE, ADVICE, DEVICE);
	cudaMemset(dev_mallo, value=1, SIZE);
//	cudaFuncSetAttribute(shm_foo, cudaFuncAttributePreferredSharedMemoryCarveout, carveout); // split shared memory as 96/64/32/16/8/0 KB from unified shared/L1_cache memory.

	/* memory copy */
	cudaMemcpy(dev_malloc, host_malloc, SIZE, cudaMemcpyHostToDevice);
	cudaMemcpy(host_malloc, dev_malloc, SIZE, cudaMemcpyDeviceToHost);
	int stream=0;
	cudaMemcpyAsync(dev_malloc, host_pinned, SIZE/4, cudaMemcpyHostToDevice, ++stream);
	cudaMemcpyPeer(dev2_malloc, 1, dev_malloc, 0, SIZE); // memory copy from GPU 0's memory to GPU 1's memory
	cudaMemcpyPeerAsync(dev2_malloc, 1, dev_malloc, 0, SIZE/4, ++stream); // memory copy from GPU 0's memory to GPU 1's memory

	shm_foo<<<1,1>>>();
	cout << var[0] << var[1] <<endl;

	/* free */
	cudaFreeHost(host_pinned);
	cudaFree(uvm_managed);
	cudaFree(pitched);
	cudaFree(dev_malloc);
	cudaFree(dev2_malloc);

	return 0;
}
