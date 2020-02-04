FROM nvidia/cuda

COPY matmul.cu /

RUN [ "nvcc","-arch=sm_61", "matmul.cu" ]
RUN ["nvprof","/a.out"]
RUN ["/a.out"]

