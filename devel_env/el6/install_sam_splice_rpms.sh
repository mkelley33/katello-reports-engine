#!/bin/sh
# Hostname for instance serving splice RPMs
BUILDER_ADDR=ec2-23-22-86-129.compute-1.amazonaws.com

# Install EPEL
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm || {
    echo "Unable to install EPEL"
    exit 1;
}
# Install Splice RPMs
wget http://${BUILDER_ADDR}/pub/splice_el6_x86_64.repo -O /etc/yum.repos.d/splice_el6_x86_64.repo || {
    echo "Unable to download the yum repo configuration for splice: splice.repo"
    exit 1;
}

# Use latest compose thats been uploaded
if [ ! -f /etc/yum/repos.d/sam-1.3.repo ]; then
    cat > /etc/yum.repos.d/sam-1.3.repo << EOF
[sam-1.3]
name=sam-1.3
baseurl=http://${BUILDER_ADDR}/pub/sam/nightly
enabled=1
gpgcheck=0
EOF
fi

rpm -Uvh http://fedorapeople.org/groups/katello/releases/yum/nightly/RHEL/6Server/x86_64/katello-repos-latest.rpm


# Set hostname of instance to EC2 public hostname
HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
hostname ${HOSTNAME}
sed -i "s/^HOSTNAME.*/HOSTNAME=${HOSTNAME}/" /etc/sysconfig/network


setenforce 0
sed -i "s/^SELINUX.*/SELINUX=permissive/" /etc/selinux/config

service iptables stop
chkconfig iptables off

yum-config-manager --enable rhel-6-server-optional-rpms
yum install -y katello-headpin-all ruby193-rubygem-splice_reports splice spacewalk-splice-tool

chkconfig mongod on
service mongod start

katello-configure --reset-data=YES --user-pass admin --deployment=sam
katello-service stop
katello-service start



