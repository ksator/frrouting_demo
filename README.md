# About this repository

Free Range Routing (FRR) demo using Docker Compose

There are two ways of configuring FRR:
- Traditionally each of the daemons had its own config file. For example, zebra’s config file was zebra.conf. This method is deprecated.
- Because of the amount of config files this creates, and the tendency of one daemon to rely on others for certain functionality, most deployments now use the integrated configuration mode.  All configuration goes into a single file (frr.conf), for all daemons. This replaces the individual files like zebra.conf or bgpd.conf.

This repository has 2 demo. The 2 demos uses the same [Dockerfile file](Dockerfile).
- demo 1:
  - Integrated configuration mode
  - The docker-compose file is [docker-compose-demo1.yml](docker-compose-demo1.yml)
  - 2 FRR containers configured with these files [frrouting_demo/demo1](frrouting_demo/demo1)
- demo 2:
  - Old configuration mode
  - The docker-compose file os [docker-compose-demo2.yml](docker-compose-demo2.yml)
  - 2 FRR containers configured with these files [frrouting_demo/demo2](frrouting_demo/demo2)

# Requirements to run this repository

- Install Docker
- Install Docker Compose

```
docker --version
Docker version 20.10.1, build 831ebea
```
```
docker-compose --version
docker-compose version 1.27.4, build 40524192
```

# Instructions to use this repository

- Clone this repository
```
git clone https://github.com/ksator/frrouting_demo.git
```
- Move to the local directory
```
cd frrouting_demo
```

## demo 1 (Integrated configuration mode)

- Run this command to:
  - Create the networks
  - Build the docker image
  - Create the containers
  - Start the containers

```
docker-compose -f docker-compose-demo1.yml up -d
Creating network "frrouting_demo_net1" with driver "bridge"
Creating network "frrouting_demo_net100" with driver "bridge"
Creating network "frrouting_demo_net200" with driver "bridge"
Creating frr200 ... done
Creating frr100 ... done
```
- Run these commands to verify:
```
docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS     NAMES
a74da765af56   ksator/frr:1.0   "/bin/bash /etc/frr/…"   12 seconds ago   Up 10 seconds             frr100
31bb4043bd89   ksator/frr:1.0   "/bin/bash /etc/frr/…"   12 seconds ago   Up 9 seconds              frr200

docker images
REPOSITORY         TAG           IMAGE ID       CREATED             SIZE
ksator/frr         1.0           335df45c9368   About an hour ago   311MB
ubuntu             20.04         9873176a8ff5   46 hours ago        72.7MB

docker network ls | grep frr
165c0c408e97   frrouting_demo_net1     bridge    local
fe458082cac9   frrouting_demo_net100   bridge    local
bcaea070a399   frrouting_demo_net200   bridge    local

docker-compose -f docker-compose-demo1.yml ps
 Name               Command               State   Ports
-------------------------------------------------------
frr100   /bin/bash /etc/frr/start_f ...   Up
frr200   /bin/bash /etc/frr/start_f ...   Up
```

## demo 2 (old configuration mode)
