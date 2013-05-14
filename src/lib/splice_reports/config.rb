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

