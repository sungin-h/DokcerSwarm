# DokcerSwarm
Practice for using docker swarm

# Enable Docker Swarm
1. Open a terminal, and initialize Docker Swarm mode on Manager node:
<div>docker swarm init</div>

If all goes well, you should see a message similar to the following:
<div> Swarm initialized: current node (tjjggogqpnpj2phbfbz8jd5oq) is now a manager.
 To add a worker to this swarm, run the following command:
 docker swarm join --token SWMTKN-1-3e0hh0jd5t4yjg209f4g5qpowbsczfahv2dea9a1ay2l8787cf-2h4ly330d0j917ocvzw30j5x9 192.168.65.3:2377
 To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.</div>

# My platform configuration
Two nodes, a manager and a worker
Manager : contains one V100 GPU(GDDR5 16GB)
Worker : four V100 GPUs(HBM 32GB) linked with NVLINK
Those nodes are connected in a same network.


# Reference
**Official document on Docker**
https://docs.docker.com

**docker command line reference**
https://docs.docker.com/engine/reference/commandline/docker/

**swarm command line reference**
https://docs.docker.com/engine/reference/commandline/swarm_init/
