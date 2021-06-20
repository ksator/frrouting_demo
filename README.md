# About this repository

Free Range Routing (FRR) demo using Docker Compose

There are two ways of configuring FRR:
- Traditionally each of the daemons had its own config file. For example, zebra’s config file was `zebra.conf`. This method is deprecated.
- Most deployments now use the integrated configuration mode.  All configuration goes into a single file (`frr.conf`), for all daemons. This replaces the individual files like `zebra.conf` or `bgpd.conf`.

This repository has 2 demo. The 2 demos uses the same [Dockerfile file](Dockerfile).
- demo 1:
  - Integrated configuration mode
  - The docker-compose file is [docker-compose-demo1.yml](docker-compose-demo1.yml)
  - 2 FRR containers configured with these files [demo1](demo1)
- demo 2:
  - Old configuration mode
  - The docker-compose file is [docker-compose-demo2.yml](docker-compose-demo2.yml)
  - 2 FRR containers configured with these files [demo2](demo2)

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
git clone https://gitlab.aristanetworks.com/emea-se-team/frrouting_demo.git
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
- Run these commands on the host to verify:
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
- Run this command to get into frr100 container shell  
```
docker exec -it frr100 bash
```
- Run these commands on the frr100 container 
```
root@ad7ea78b29dd:/# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
358: eth1@if359: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:c0:a8:64:64 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.100.100/24 brd 192.168.100.255 scope global eth1
       valid_lft forever preferred_lft forever
362: eth0@if363: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:c0:a8:01:64 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
       valid_lft forever preferred_lft forever

root@ad7ea78b29dd:/# ls -l /etc/frr/
total 20
-rw-rw-r-- 1 frr frr 2580 Jun 19 21:33 daemons
-rw-rw-r-- 1 frr frr  647 Jun 19 21:33 frr.conf
-rw-rw-r-- 1 frr frr   60 Jun 19 21:33 start_frr.sh
-rw-rw-r-- 1 frr frr 3581 Jun 19 21:33 support_bundle_commands.conf
-rw-rw-r-- 1 frr frr   32 Jun 19 21:33 vtysh.conf

root@ad7ea78b29dd:/# more /etc/frr/daemons | grep bgpd=
bgpd=yes

root@ad7ea78b29dd:/# service frr status
 * Status of watchfrr: running
 * Status of zebra: running
 * Status of bgpd: running
 * Status of staticd: running

root@ad7ea78b29dd:/# ps -ef | grep frr
root         1     0  0 09:44 ?        00:00:00 /bin/bash /etc/frr/start_frr.sh
root        19     1  0 09:44 ?        00:00:00 /usr/lib/frr/watchfrr -d -F traditional zebra bgpd staticd
frr         35     1  0 09:44 ?        00:00:00 /usr/lib/frr/zebra -d -F traditional -A 127.0.0.1 -s 90000000
frr         42     1  0 09:44 ?        00:00:00 /usr/lib/frr/bgpd -d -F traditional -A 127.0.0.1
frr         51     1  0 09:44 ?        00:00:00 /usr/lib/frr/staticd -d -F traditional -A 127.0.0.1
root        94    69  0 09:45 pts/0    00:00:00 grep --color=auto frr
```
`vtysh` provides a combined frontend to all FRR daemons in a single combined session
```
root@ad7ea78b29dd:/# vtysh 

Hello, this is FRRouting (version 7.5.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

ad7ea78b29dd# show int brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         192.168.1.100/24
eth1            up      default         192.168.100.100/24
lo              up      default         

ad7ea78b29dd# sho bgp summary 

IPv4 Unicast Summary:
BGP router identifier 192.168.100.100, local AS number 65100 vrf-id 0
BGP table version 3
RIB entries 5, using 960 bytes of memory
Peers 1, using 21 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
192.168.1.200   4      65200        19        18        0    0    0 00:13:28            1        1

Total number of neighbors 1

ad7ea78b29dd# sho ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

K>* 0.0.0.0/0 [0/0] via 192.168.1.1, eth0, 00:13:32
C>* 192.168.1.0/24 is directly connected, eth0, 00:13:32
C>* 192.168.100.0/24 is directly connected, eth1, 00:13:32
B>* 192.168.200.0/24 [20/0] via 192.168.1.200, eth0, weight 1, 00:13:26

ad7ea78b29dd# ping 192.168.200.200
PING 192.168.200.200 (192.168.200.200) 56(84) bytes of data.
64 bytes from 192.168.200.200: icmp_seq=1 ttl=64 time=0.382 ms
64 bytes from 192.168.200.200: icmp_seq=2 ttl=64 time=0.758 ms
^C
--- 192.168.200.200 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1018ms
rtt min/avg/max/mdev = 0.382/0.570/0.758/0.188 ms

ad7ea78b29dd# show running-config 
Building configuration...

Current configuration:
!
frr version 7.5.1
frr defaults traditional
hostname ad7ea78b29dd
log syslog informational
no ipv6 forwarding
service integrated-vtysh-config
!
password arista
enable password arista
!
interface eth0
 description to bgp peer
!
interface eth1
 description LAN
!
router bgp 65100
 neighbor 192.168.1.200 remote-as 65200
 neighbor 192.168.1.200 password arista
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor 192.168.1.200 route-map IMPORT in
  neighbor 192.168.1.200 route-map EXPORT out
 exit-address-family
!
route-map EXPORT permit 10
 match interface eth1
!
route-map EXPORT deny 100
!
route-map IMPORT permit 10
!
line vty
!
end
ad7ea78b29dd# exit
```
you can telnet a daemon (if the daemon config has a password)
```
root@ad7ea78b29dd:/# more /etc/services | grep zebra
zebrasrv        2600/tcp                        # zebra service
zebra           2601/tcp                        # zebra vty
ripd            2602/tcp                        # ripd vty (zebra)
ripngd          2603/tcp                        # ripngd vty (zebra)
ospfd           2604/tcp                        # ospfd vty (zebra)
bgpd            2605/tcp                        # bgpd vty (zebra)
ospf6d          2606/tcp                        # ospf6d vty (zebra)
isisd           2608/tcp                        # ISISd vty (zebra)
```
telnet bgpd
```
root@ad7ea78b29dd:/# telnet localhost 2605
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

Hello, this is FRRouting (version 7.5.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.


User Access Verification

Password: 
ad7ea78b29dd> en
Password: 
ad7ea78b29dd# sh bgp summary 

IPv4 Unicast Summary:
BGP router identifier 192.168.100.100, local AS number 65100 vrf-id 0
BGP table version 3
RIB entries 5, using 960 bytes of memory
Peers 1, using 21 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
192.168.1.200   4      65200        11        10        0    0    0 00:05:17            1        1

Total number of neighbors 1

ad7ea78b29dd# sho running-config 

Current configuration:
!
frr version 7.5.1
frr defaults traditional
!
hostname 54124bfdab91
password arista
enable password arista
log syslog informational
!
!
!
router bgp 65100
 neighbor 192.168.1.200 remote-as 65200
 neighbor 192.168.1.200 password arista
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor 192.168.1.200 route-map IMPORT in
  neighbor 192.168.1.200 route-map EXPORT out
 exit-address-family
!
!
!
route-map EXPORT permit 10
 match interface eth1
route-map EXPORT deny 100
!
route-map IMPORT permit 10
!
!
line vty
!
end

ad7ea78b29dd# exit
Connection closed by foreign host.
```
telnet zebra
```
root@ad7ea78b29dd:/# telnet localhost 2601
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

Hello, this is FRRouting (version 7.5.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.


User Access Verification

Password: 
ad7ea78b29dd> en
Password: 
ad7ea78b29dd# sh ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

K>* 0.0.0.0/0 [0/0] via 192.168.1.1, eth0, 00:06:26
C>* 192.168.1.0/24 is directly connected, eth0, 00:06:26
C>* 192.168.100.0/24 is directly connected, eth1, 00:06:26
B>* 192.168.200.0/24 [20/0] via 192.168.1.200, eth0, weight 1, 00:06:20


ad7ea78b29dd# show running-config 

Current configuration:
!
frr version 7.5.1
frr defaults traditional
!
hostname 54124bfdab91
password arista
enable password arista
log syslog informational
!
!
!
!
interface eth0
 description to bgp peer
!
interface eth1
 description LAN
!
!
route-map EXPORT permit 10
 match interface eth1
route-map EXPORT deny 100
!
route-map IMPORT permit 10
!
!
no ipv6 forwarding
!
!
!
line vty
!
end

ad7ea78b29dd# exit
Connection closed by foreign host.
root@ad7ea78b29dd:/#
```

Run this command to exit the frr100 container shell 
```
root@ad7ea78b29dd:/# exit
exit
```
Run this command on the host to:
- Stop the containers
- Remove the containers
- Remove the networks
```
docker-compose -f docker-compose-demo1.yml down
Stopping frr100 ... done
Stopping frr200 ... done
Removing frr100 ... done
Removing frr200 ... done
Removing network frrouting_demo_net1
Removing network frrouting_demo_net100
Removing network frrouting_demo_net200
```

## demo 2 (old configuration mode)

- Run this command to:
  - Create the networks
  - Build the docker image
  - Create the containers
  - Start the containers
```
docker-compose -f docker-compose-demo2.yml up -d
Creating network "frrouting_demo_net1" with driver "bridge"
Creating network "frrouting_demo_net100" with driver "bridge"
Creating network "frrouting_demo_net200" with driver "bridge"
Creating frr200 ... done
Creating frr100 ... done
```
- Run this command to get into frr100 container shell  
```
docker exec -it frr100 bash
```
- Run these commands on the frr100 container 
```
root@81bb8c310df9:/# ls -l /etc/frr/
total 28
-rw-rw-r-- 1 frr frr  593 Jun 19 21:33 bgpd.conf
-rw-rw-r-- 1 frr frr 2580 Jun 19 21:33 daemons
-rw-rw-r-- 1 frr frr   60 Jun 19 21:33 start_frr.sh
-rw-rw-r-- 1 frr frr  213 Jun 19 21:33 staticd.conf
-rw-rw-r-- 1 frr frr 3581 Jun 19 21:33 support_bundle_commands.conf
-rw-rw-r-- 1 frr frr   35 Jun 19 21:33 vtysh.conf
-rw-rw-r-- 1 frr frr  426 Jun 19 21:33 zebra.conf
root@81bb8c310df9:/# 
```
`vtysh` provides a combined frontend to all FRR daemons in a single combined session
```
root@81bb8c310df9:/# vtysh 

Hello, this is FRRouting (version 7.5.1).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

81bb8c310df9# show bgp summary 

IPv4 Unicast Summary:
BGP router identifier 192.168.100.100, local AS number 65100 vrf-id 0
BGP table version 3
RIB entries 5, using 960 bytes of memory
Peers 1, using 21 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt
192.168.1.200   4      65200         8         9        0    0    0 00:03:11            1        1

Total number of neighbors 1

81bb8c310df9# sho ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, D - SHARP,
       F - PBR, f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup

K>* 0.0.0.0/0 [0/0] via 192.168.1.1, eth0, 00:03:16
C>* 192.168.1.0/24 is directly connected, eth0, 00:03:16
C>* 192.168.100.0/24 is directly connected, eth1, 00:03:16
B>* 192.168.200.0/24 [20/0] via 192.168.1.200, eth0, weight 1, 00:03:09

81bb8c310df9# ping 192.168.200.200
PING 192.168.200.200 (192.168.200.200) 56(84) bytes of data.
64 bytes from 192.168.200.200: icmp_seq=1 ttl=64 time=0.446 ms
64 bytes from 192.168.200.200: icmp_seq=2 ttl=64 time=0.712 ms
64 bytes from 192.168.200.200: icmp_seq=3 ttl=64 time=0.670 ms
^C
--- 192.168.200.200 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2034ms
rtt min/avg/max/mdev = 0.446/0.609/0.712/0.116 ms

81bb8c310df9# show running-config 
Building configuration...

Current configuration:
!
frr version 7.5.1
frr defaults traditional
hostname 11e2fca915a9
log syslog informational
no ipv6 forwarding
hostname 81bb8c310df9
no service integrated-vtysh-config
!
password arista
enable password arista
!
interface eth0
 description to bgp peer
!
interface eth1
 description LAN
!
router bgp 65100
 neighbor 192.168.1.200 remote-as 65200
 neighbor 192.168.1.200 password arista
 !
 address-family ipv4 unicast
  redistribute connected
  neighbor 192.168.1.200 route-map IMPORT in
  neighbor 192.168.1.200 route-map EXPORT out
 exit-address-family
!
route-map EXPORT permit 10
 match interface eth1
!
route-map EXPORT deny 100
!
route-map IMPORT permit 10
!
line vty
!
end
81bb8c310df9# exit
```
Run this command to exit the frr100 container shell 
```
root@81bb8c310df9:/# exit
exit
```
Run this command on the host to:
- Stop the containers
- Remove the containers
- Remove the networks
```
docker-compose -f docker-compose-demo2.yml down
Stopping frr100 ... done
Stopping frr200 ... done
Removing frr100 ... done
Removing frr200 ... done
Removing network frrouting_demo_net1
Removing network frrouting_demo_net100
Removing network frrouting_demo_net200
```

