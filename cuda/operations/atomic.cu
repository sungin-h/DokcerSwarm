#include <iostream>
#include <cuda.h>
#include <cuda_runtime_api.h>


__global__ void mykernel(int *addr){
	int min=1000, max=-1;
	int val = 10;
	atomicAdd(addr, 10);
	atomicSub(addr, 5);
	atomicExch(addr, 20);
	atomicMin(addr, min);
	atomicMax(addr, max);
	atomicInc(addr, val); // old >= val ? 0: ++old
	atomicDec(addr, val); // (old == 0) || (old > val) ? val : --old
	atomicCAS(addr, compare, val); // old==compare ? val : old
	atomicAnd(addr, val);
	atomicOr(addr, val);
	atommicXor(addr, val);
}


int main(){

	cudaSetDevice(0);
	int *addr;
	cudaMallocManaged(&addr, 4);
	*addr=0;

	mykernel<<<1,1>>>(addr);

	__sync_fetch_and_add(addr,10); // CPU atomic add operation

	return 0;

}
