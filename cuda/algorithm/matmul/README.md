## Build docker image
docker build -t {name:tag} . 
#. is path to directory which contains Dockerfile

## Run container from the image
docker run -it --gpus all --privileged {name:tag} 
# to profile using nvprof --privileged option is required 
