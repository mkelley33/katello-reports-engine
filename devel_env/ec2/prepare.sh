HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
hostname ${HOSTNAME}
sed -i "s/^HOSTNAME.*/HOSTNAME=${HOSTNAME}/" /etc/sysconfig/network

yum -y install git
cd /
git clone https://github.com/Katello/katello.git
git clone https://github.com/splice/splice-reports.git

