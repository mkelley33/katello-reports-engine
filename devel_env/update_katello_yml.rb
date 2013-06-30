#!/usr/bin/env ruby

require 'yaml'

def get_config(path)
  YAML.load_file(path)
end

def modify_config(cfg)
  prod_db = cfg["production"]["database"]
  username = prod_db["username"]
  password = prod_db["password"]
  database = prod_db["database"]

  db_types = [ "development", "test"]
  db_types.map do |db_type|
    section = cfg[db_type] = {}
    db = section["database"] = {}
    db["username"] = username
    db["password"] = password
    if db_type == "test"
      db["database"] = "katello_test"
    else
      db["database"] = database
    end
  end
  cfg["test"]["database"]["adapter"] = "postgresql"
  cfg["test"]["database"]["host"] = "localhost"
  cfg["test"]["database"]["encoding"] = "UTF8"
  cfg
end

def save_config(cfg, path)
  File.open(path, "w") do |file|
    file.write(cfg.to_yaml)
  end
end

def update_katello_config(config_file)
    cfg = get_config(config_file)
    cfg = modify_config(cfg)
    save_config(cfg, config_file)
end

if __FILE__ == $0
  config_file = ARGV[0]
  if config_file.nil?
    print "Please re-run with path to katello.yml specified"
    exit 1
  end
  update_katello_config(config_file)
  puts "#{config_file} has been updated by #{$0}"
end

