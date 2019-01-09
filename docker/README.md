## Env Required

- centos 7.x

- 3.10.0-514.16.1.el7.x86_64

-  xfs ftype=1

```bash
overlay2: the backing xfs filesystem is formatted without d_type support, which leads to incorrect behavior.
         Reformat the filesystem with ftype=1 to enable d_type support.
         Running without d_type support will not be supported in future releases.
```

## Get Binary Tgz

```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-18.09.0.tgz
```

## Install Docker CE 

```bash
sh docker-init.sh docker-18.09.0.tgz
```

## Check Install

```bash
docker  version 
docker  info
```
