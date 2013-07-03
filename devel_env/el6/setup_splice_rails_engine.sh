#!/bin/bash

source env_vars

wget http://ec2-23-22-86-129.compute-1.amazonaws.com/pub/splice_el6_x86_64.repo -O /etc/yum.repos.d/splice_el6_x86_64.repo
wget http://repos.fedorapeople.org/repos/candlepin/subscription-manager/epel-subscription-manager.repo -O /etc/yum.repos.d/epel-subscription-manager.repo

# Install deps for splice-reports
yum -y install ruby193-rubygem-mongo ruby193-rubygem-bson_ext ruby193-rubygem-zipruby
yum -y install mongodb-server v8

yum -y install spacewalk-splice-tool

# Install splice-reports Rails engine into Katello
cat <<EOF > ${KATELLO_GIT_PATH}/bundler.d/splice_reports.rb
    gem 'splice_reports', :path => "${SPLICE_REPORTS_GIT_PATH}"
EOF

if [ ! -e /etc/splice ]; then
  mkdir /etc/splice
fi

if [ ! -f /etc/splice/splice_reports.yml ]; then
  ln -s ${SPLICE_REPORTS_GIT_PATH}/etc/splice/splice_reports.yml /etc/splice/splice_reports.yml
fi

if [ ! -e /etc/pki/splice ]; then
  mkdir /etc/pki/splice
fi

if [ ! -f /etc/pki/splice/splice_reports_key.gpg.pub ]; then
  ln -s ${SPLICE_REPORTS_GIT_PATH}/etc/pki/splice/splice_reports_key.gpg.pub /etc/pki/splice/splice_reports_key.gpg.pub
fi


# Run bundle install on katello
scl enable ruby193 "cd ${KATELLO_GIT_PATH} && bundle install"
# Note, splice_reports no longer requires a "railties:install:migrations" do not run that command
# it will cause migrations to be added twice resulting in an error: Multiple migrations have the name ..."
scl enable ruby193 "cd ${KATELLO_GIT_PATH} && rake db:migrate"

#install deps for sample data
yum -y install python-mongoengine pymongo

#load sample data
pushd /vagrant/playpen/create_sample_data/
/vagrant/playpen/create_sample_data/create.py -u 10
/vagrant/playpen/create_sample_data/load_data.py -d
popd


echo "The 'splice_reports' rails engine: ${SPLICE_REPORTS_GIT_PATH} has been configured for ${KATELLO_GIT_PATH}"

echo "Please run the below to bring up the Katello Development Server:"
echo " On your main devel machine:"
echo "  1) Ensure that there is an entry for the VM's hostname: splice.example.com in /etc/hosts"
echo ""
echo " On the newly created VM:"
echo " 1) cd ${KATELLO_GIT_PATH}"
echo " 2) sudo scl enable ruby193 'rails s'"
echo "Enjoy."
=======
