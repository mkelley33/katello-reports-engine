#!/usr/bin/env python
import os
import sys
import time
from launch_instance import launch_instance, get_opt_parser, ssh_command, scp_to_command, run_command, tag_instance
from optparse import OptionParser
from datetime import datetime

SCRIPT_DIR="../el6/"

if __name__ == "__main__":
    start = time.time()
    compose=1
    parser = OptionParser()
    parser = get_opt_parser(parser=parser)
    (opts, args) = parser.parse_args()
    instance = launch_instance(opts)
    if not instance or not hasattr(instance, "dns_name"):
        print "Failed to launch an instance. Will exit"
        sys.exit(1)
    hostname = instance.dns_name
    ssh_key = opts.ssh_key
    ssh_user = opts.ssh_user
    #
    # open firewall
    #
    print "Updating firewall rules"
    ssh_command(hostname, ssh_user, ssh_key, "mkdir -p ~/etc/sysconfig")
    scp_to_command(hostname, ssh_user, ssh_key, "./etc/sysconfig/iptables", "~/etc/sysconfig/iptables")
    ssh_command(hostname, ssh_user, ssh_key, "sudo mv ~/etc/sysconfig/iptables /etc/sysconfig/iptables")
    ssh_command(hostname, ssh_user, ssh_key, "sudo restorecon /etc/sysconfig/iptables")
    ssh_command(hostname, ssh_user, ssh_key, "sudo chown root:root /etc/sysconfig/iptables")
    ssh_command(hostname, ssh_user, ssh_key, "sudo service iptables restart")
    #
    # Copy scripts over
    #
    scp_to_command(hostname, ssh_user, ssh_key, "./env_vars", "~")
    scp_to_command(hostname, ssh_user, ssh_key, "./prepare.sh", "~")
    ssh_command(hostname, ssh_user, ssh_key, "chmod +x ./prepare.sh")
    scp_to_command(hostname, ssh_user, ssh_key, "%s/../*.rb" % (SCRIPT_DIR), "~")
    scp_to_command(hostname, ssh_user, ssh_key, "%s/setup_katello_devel_env.sh" % (SCRIPT_DIR), "~")
    ssh_command(hostname, ssh_user, ssh_key, "chmod +x ./setup_katello_devel_env.sh")
    scp_to_command(hostname, ssh_user, ssh_key, "%s/setup_splice_rails_engine.sh" % (SCRIPT_DIR), "~")
    ssh_command(hostname, ssh_user, ssh_key, "chmod +x ./setup_splice_rails_engine.sh")
    scp_to_command(hostname, ssh_user, ssh_key, "%s/run_rails.sh" % (SCRIPT_DIR), "~")
    ssh_command(hostname, ssh_user, ssh_key, "chmod +x ./run_rails.sh")
    #
    # Run install script
    #
    print "Set hostname and checkout git repos"
    ssh_command(hostname, ssh_user, ssh_key, "time sudo ./prepare.sh &> ./prepare.log")

    print "Setup Katello Devel Env"
    ssh_command(hostname, ssh_user, ssh_key, "time sudo ./setup_katello_devel_env.sh &> ./setup_katello_devel_env.log")

    print "Install SpliceReports"
    ssh_command(hostname, ssh_user, ssh_key, "time sudo ./setup_splice_rails_engine.sh &> ./setup_splice_rails_engine.log")

    print "Kicking off Rails server in screen session"
    ssh_command(hostname, ssh_user, ssh_key, "time sudo ./run_rails.sh &> ./run_rails.log")
    #
    # Update EC2 tag with version of RCS installed
    #
    datestmp = datetime.now().strftime("%Y-%m-%d %H:%M")
    tag = tag_instance(instance, hostname, ssh_user, ssh_key, data="Splice Devel Env %s" % (datestmp))

    end = time.time()
    print "%s install completed on: %s in %s seconds" % (tag, hostname, end-start)
    print "Visit http://%s:3000/katello to see the webui" % (hostname)


