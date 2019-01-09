#!/bin/bash
usage(){
  echo "Usage: $0 FILE_NAME_DOCKER_CE_TAR_GZ"
  echo "       $0 docker-18.09.0-ce.tgz"
  echo "Get docker-ce binary from: https://download.docker.com/linux/static/stable/x86_64/"
  echo "eg: wget https://download.docker.com/linux/static/stable/x86_64/docker-17.09.0-ce.tgz"
  echo "" 
}

# Vars
SYSTEMDDIR=/usr/lib/systemd/system
SERVICEFILE=docker.service
DOCKERDIR=/usr/bin
DOCKERBIN=docker
SERVICENAME=docker

# check installed status
which docker

if [ $? -eq 0 ];then
  echo "Pls uninstall  docker first, then start install"
  exit
fi

# Var nums check
if [ $# -ne 1 ];then
  usage
  exit 1
else
  FILETARGZ="$1"
fi

if [ != ${FILETARGZ} ];then
  echo "Docker binary tgz files does not exist, please check it"
  echo "Get docker-ce binary from: https://download.docker.com/linux/static/stable/x86_64/"
  echo "eg: wget https://download.docker.com/linux/static/stable/x86_64/docker-18.09.0.tgz"
fi

echo "## step1, unzip: tar -zxvf ${FILETARGZ}"
tar -zxvf ${FILETARGZ}

echo "## step2, binary :copy  ${DOCKERBIN} to ${DOCKERDIR}"
cp -p ${DOCKERBIN}/* ${DOCKERDIR} >/dev/null 2>&1
which ${DOCKERBIN}  
echo "## step3, systemd service: create docker systemd file,  ${SERVICEFILE}"
cat >${SYSTEMDDIR}/${SERVICEFILE} <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket
[Service]
Type=notify
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/dockerd --storage-opt overlay2.override_kernel_check=1  --storage-driver=overlay2 --graph=/home/docker_rt \
                --selinux-enabled=false \
                --log-opt max-size=1g
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
# Uncomment TasksMax if your systemd version supports it.
LimitNOFILE=1000000
LimitNPROC=100000
LimitCORE=102400000000
LimitSTACK=104857600
LimitSIGPENDING=600000
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

echo ""

systemctl daemon-reload

echo "step4 check install status:"
systemctl status ${SERVICENAME}
echo "##Service restart: ${SERVICENAME}"
systemctl restart ${SERVICENAME}
echo "##Service status: ${SERVICENAME}"
systemctl status ${SERVICENAME}

echo "##Service enabled: ${SERVICENAME}"
systemctl enable ${SERVICENAME}

echo "## docker version"
docker version
