# Following: https://fedorahosted.org/katello/wiki/DevelopmentSetup

source env_vars

setenforce 0
sed -i "s/^SELINUX.*/SELINUX=permissive/" /etc/selinux/config

service iptables stop
chkconfig iptables off

rpm -Uvh http://fedorapeople.org/groups/katello/releases/yum/nightly/RHEL/6/x86_64/katello-repos-latest.rpm
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

yum groupinstall -y "Development Tools"
yum install -y ruby-devel ruby193-ruby-devel postgresql-devel sqlite-devel libxml2 libxml2-devel libxslt libxslt-devel git

yum install -y katello-all

katello-configure --user-pass admin

rpm -e --nodeps ruby193-rubygem-ruport

chmod -R 777 /etc/katello

# Disable katello service from running since we will run devel server
service katello-jobs stop; service katello stop
chkconfig katello-jobs off; chkconfig katello off

# Update katello.yml with development/test DBs
cp /etc/katello/katello.yml ${KATELLO_GIT_PATH}/config/katello.yml
../update_katello_yml.rb ${KATELLO_GIT_PATH}/config/katello.yml

# Modify DB access
cat >/var/lib/pgsql/data/pg_hba.conf <<EOF
# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
local   all         all                               trust
host    all         all         127.0.0.1/32          trust
host    all         all         ::1/128               trust
EOF

service postgresql restart

scl enable ruby193 "cd ${KATELLO_GIT_PATH} && bundle install"
cd ${KATELLO_GIT_PATH} && echo "yes" | scl enable ruby193 "./script/katello-reset-dbs development ."
echo "Katello devel enviroment is setup"
echo "Please run the below to bring up the Katello Development Server:"
echo " ** If setting this up in VM, ensure you ssh into the VM prior to running below**"
echo " 1) cd ${KATELLO_GIT_PATH}"
echo " 2) sudo scl enable ruby193 'rails s'"
echo "Enjoy."


