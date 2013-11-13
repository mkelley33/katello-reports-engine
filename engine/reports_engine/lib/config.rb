#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


require 'yaml'

module SpliceReports

  class Configuration
    @@config_file_path = "/etc/splice/splice_reports.yml"
    class << self
      attr_accessor :config
    end

    def self.load
      if not File.exist? @@config_file_path or not File.readable? @@config_file_path
        raise "Unable to find/read config file: #{@@config_file_path}"
      end
      self.config = YAML.load_file(@@config_file_path)
    end

  end
end

