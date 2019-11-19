# About
**MAIO - MogileFS All In One** provides a way to set up a minimal [MogileFS](https://github.com/mogilefs/mogilefs-wiki) cluster without pain. Tracker, stored and tracker DB are instantiated in a single container. It is suitable for testing and developing scenarios. 

# Highlight
 - Based on the latest version: MogileFS-Server 2.73 / MogileFS-Utils 2.30 / MogileFS-Network 0.06 
 - All in one. No additional dependency. 
 - The domain/class is configurable.
 - Quality and compatibility - Continuous test and build against the latest Docker version
 - Contributor friendly - typical contribution process, no weird policies
 
# How to use this image

Starting a MogileFS instance is simple:

`docker run -t -d -p 7001:7001 -p 7500:7500 --name maio hrchu/mogilefs-all-in-one`

That's it! Now MogileFS is ready to war on port 7001/7500! 😎

You can confirm it by either:
```
#echo '!jobs' |nc localhost 7001 
delete count 1
delete desired 1
delete pids 402
fsck count 1
fsck desired 1
fsck pids 405
job_master count 1
job_master desired 1
job_master pids 404
monitor count 1
monitor desired 1
monitor pids 399
queryworker count 5
queryworker desired 5
queryworker pids 406 407 408 409 410
reaper count 1
reaper desired 1
reaper pids 401
replicate count 1
replicate desired 1
replicate pids 403
.
```
or
```
# docker exec -it maio mogadm check
Checking trackers...
  127.0.0.1:7001 ... OK

Checking hosts...
  [ 1] mogilestorage ... OK

Checking devices...
  host device         size(G)    used(G)    free(G)   use%   ob state   I/O%
  ---- ------------ ---------- ---------- ---------- ------ ---------- -----
  [ 1] dev1           478.225     60.039    418.186  12.55%  writeable   N/A
  [ 1] dev2           478.225     60.039    418.186  12.55%  writeable   N/A
  ---- ------------ ---------- ---------- ---------- ------
             total:   956.450    120.078    836.372  12.55%
```

# Caveats

## Domain/Class configuration

As shown in the previous example, you can use environment variables to specify MogileFS domain and classes:
```
docker run -e DOMAIN_NAME=testdomain -e CLASS_NAMES="testclass1 testclass2" -t -d -p 7001:7001 -p 7500:7500 --name maio hrchu/mogilefs-all-in-one`
```

## Persistent data store

You can let Docker manage the storage of your data by writing the mysql/mogstored files to disk on the host system using its own internal volume management. In this way, you can recreate the container without lossing data. An example:
```
mkdir -p /opt/maio-mysql/ /opt/mogdata/
docker rm -f maio; docker run -t -d -p 7001:7001 -p 7500:7500 --name maio mogilefs-all-in-one
```

# Contributing
All contributions are welcome. Nothing else special.

# Acknowledgement

Artifacts is based on [Jeffutter](https://hub.docker.com/r/jeffutter/mogile-tracker)'s contribution. I enjoy his work for many years. However, he does not maintain it anymore. Besides, he removed all source code, so I decided to build a new one with many improvements.
