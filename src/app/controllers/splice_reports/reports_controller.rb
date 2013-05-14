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

require 'time'
require 'tmpdir'
require 'zipruby'

module SpliceReports
  
  class ReportsController < ::ApplicationController
    
    before_filter :find_filter

    @@c = SpliceReports::MongoConn.new.get_coll_marketing_report_data()

    def self.get_gpg_public_key
      pub_key = SpliceReports::Configuration.config["export"]["public_gpg_key"]
      logger.info("SpliceReports configured to use public gpg key at: #{pub_key}")
      return pub_key
    end

    def run_filter_by_id(filter_id, offset)
      filter = SpliceReports::Filter.where(:id=>filter_id).first
      search = nil
      if params["search"] != nil
        search = params["search"]
      end
      filtered_systems = get_marketing_product_results(filter, offset, search)
      logger.info(filtered_systems.length)
      logger.info("Splice Reports, id = #{filter_id} filtered_systems: #{filtered_systems.inspect}")
      #filtered_systems = get_marketing_product_results(filter, offset)
      return filtered_systems
    end

    def get_num_summary(systems)
      debugger
      num_current = 0
      num_invalid = 0
      num_insufficient = 0
      systems.each do | system | 
        case system["status"]
        when "valid"
          num_current += 1
        when "invalid"
          num_invalid += 1
        when "partial" 
          num_insufficient += 1
        end
      end
      return {num_current: num_current, 
              num_invalid: num_invalid, 
              num_insufficient: num_insufficient,
              num_total: num_current + num_invalid + num_insufficient}
    end

    def systems_to_csv(systems)
      return "" unless systems.length > 0
      # Assuming all arrays have a hash with same keys, also assuming order of keys is same for all entries in array
      fields = systems[0].keys
      # Header
      header = ""
      fields.each { |field| header << field << ", "}
      # Body
      body_lines = systems.map { |system|
        entry = ""
        fields.each do |field| 
          if field == "_id" and system[field].key?("$oid")
            entry << system[field]["$oid"] << ", " 
          else
            entry << system[field].to_s << ", "
          end 
        end
        entry
      }
      csv_data = "#{header}\n#{body_lines.join("\n")}"
    end

    def expanded_data(systems)
      system_ids = systems.map { |system| system["_id"] }
      data = get_object_details(system_ids)
      data.to_json
    end

    def create_zip_file(now, data)
      # Returns a buffer representing contents of a zipfile
      # all processing is done in memory with no temp files written
      buffer = ""
      dir_name = "report_#{now}".gsub(":", "-")
      Zip::Archive.open_buffer(buffer, Zip::CREATE) do |archive|
        archive.add_dir(dir_name)
        data.each do |entry|
          entry.each do |filename, blob| 
            archive.add_buffer("#{dir_name}/#{filename}", blob)
          end
        end
      end
      buffer
    end

    def get_export_metadata(now, systems, filter_id)
      data = "Generated at: #{now}\n"
      data << "Number of Systems: #{systems.size}\n"
      summary = get_num_summary(systems)
      summary.each do |key, value|
        data << "\t#{key}: #{value}\n"
      end
      filter = SpliceReports::Filter.find(filter_id)
      if filter
        data << "Filter Info\n"
        filter.attributes.each do |key, value|
          data << "\t#{key}: #{value}\n"
        end
      end
      data
    end

    def get_gpgkey_name(keyring)
      output = `/usr/bin/gpg --no-default-keyring --keyring #{keyring} --list-keys`
      logger.info("Output = #{output}")
      lines = output.split("\n")
      lines.each do |line|
        #Matching string such as: "uid                  key-a (key-a generated ....)"
        match = line.match(/^uid\s*(.*)\(/)
        if match
          return match[1]
        end
      end
      logger.warn("Unable to find a GPG key name from: #{output}")
      return ""
    end

    def encrypt(data)
      pub_key_path = self.class.get_gpg_public_key()
      unless (File.exist?(pub_key_path) and File.file?(pub_key_path) and File.readable?(pub_key_path))
        raise "Unable to use public key at: #{pub_key_path}"
      end

      Dir.mktmpdir do |tmp_dir|
        keyring = "#{tmp_dir}/keyring"
        raw_file = "#{tmp_dir}/raw_data"
        encrypted_file ="#{tmp_dir}/encrypted_data"
        # Write data to file so we can encrypt it
        File.open(raw_file, 'wb') { |file| file.write(data)}
        # Import the public key to a temporary key ring
        cmd_import_pub_key = "/usr/bin/gpg --import --no-default-keyring --keyring #{keyring} #{pub_key_path}"
        system(cmd_import_pub_key)
        # Instead of hard-coding key name, we will ask gpg to us it's name 
        # needed by encryption to specify '-r'/'--recipient'
        key_name = get_gpgkey_name(keyring)
        if key_name.empty?
          raise "Unable to encrypt data, unable to use configured GPG public key: #{pub_key_path}"
        end
        logger.info("Will encrypt data for key: #{key_name}")
        cmd_encrypt ="/usr/bin/gpg --no-default-keyring --keyring #{keyring} --trust-model always --output #{encrypted_file} -ear #{key_name} #{raw_file}"
        system(cmd_encrypt)
        File.open(encrypted_file, 'rb') { |file| file.read() }
      end
    end

    before_filter :find_record, :only=>[:record, :facts, :products, :checkin_list]

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
          :items => lambda{true},
          :record => lambda{true},
          :checkin => lambda{true},
          :facts=> lambda{true},
          :products=> lambda{true},
          :checkin_list=> lambda{true},
        }

    end

    def index
      @filter = SpliceReports::Filter.find(params[:filter_id])
      filtered_systems = run_filter_by_id(@filter.id, nil).as_json
      summary = get_num_summary(filtered_systems)

      #render :partial => "reports/report"
      #render :partial => "report", :locals => {:report_invalid => @report_invalid, :report_valid => @report_valid}
      logger.info("Splice Reports id: #{@filter.id}, num_current = #{summary[:num_current]}, num_invalid = #{summary[:num_invalid]}, num_insufficient = #{summary[:num_insufficient]}")
      render 'show', :locals => {:filter_id => @filter.id,  :experimental_ui => true,
                                  :num_current => summary[:num_current], 
                                  :num_invalid => summary[:num_invalid], 
                                  :num_insufficient => summary[:num_insufficient], 
                                  :num_total => summary[:num_total]}
    end

    def items
      logger.info("params = #{params}")
      respond_to do |format|
        format.zip do
          # Grab the data
          filtered_systems = self.run_filter_by_id(params[:filter_id], nil)
          # Create a zip file in memory
          now = Time.now.utc.iso8601
          file_name = "report_#{now}.zip"
          csv_data = systems_to_csv(filtered_systems.as_json)
          metadata = get_export_metadata(now, filtered_systems, params[:filter_id])
          files = ["export.csv" => csv_data, "metadata" => metadata]
          unless params.include?(:skip_expand) and params[:skip_expand] == "1"
            expanded_data = expanded_data(filtered_systems)
            files.push({"expanded_export.json" => expanded_data})
          end
          zipped_data = create_zip_file(now, files)
          if params.include?(:encrypt) and params[:encrypt] == "1"
            zipped_data = encrypt(zipped_data)
            file_name = "#{file_name}.gpg"
          end
          send_data zipped_data, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
        end
        format.any(:json, :html) do
          filtered_systems = self.run_filter_by_id(params[:filter_id], params[:offset] || 0)
          total = self.run_filter_by_id(params[:filter_id], nil).count
          render :json=>{ :subtotal=>total, :total=>total, :systems=> filtered_systems } 
        end
      end
    end

    def get_object_details(ids)
      @@c.find({"_id" => {"$in" => ids}})
    end


    def get_marketing_product_results(filter, offset, search)
      
      if filter["hours"] != nil
        end_date = Time.now.utc
        start_date = end_date - filter["hours"].hours
      elsif filter["start_date"] != nil && filter["end_date"] != nil
        end_date = filter["end_date"].utc
        start_date = filter["start_date"].utc 
      end         
      logger.info(start_date.to_s)
      logger.info(end_date.to_s)
      rules = []
      if offset
        rules << {"$skip" => offset.to_i}
        rules << {"$limit" => current_user.page_size}
      end

      if search != nil or search != ""
        logger.info("Search by filter id and search term: " + search.to_s )
        rules << {"$match" => { "facts.systemid"=> search }}
      end

      if filter["status"] == 'all'
        #do nothing
      elsif filter["status"] == 'failed'
        rules << {"$match" =>{ "$or" => [{ "entitlement_status.status" => "invalid"},
                                     { "entitlement_status.status" => "insufficient"}] } } 
      else
        rules << {"$match" =>  { "entitlement_status.status" => filter["status"]}}
      end

      result = @@c.aggregate( [
        {"$match" => {:created=> {"$gt" => start_date, "$lt" => end_date}}},
        {"$group" => {
                    '_id' => "$_id",
                    :date => {"$max" => "$created"},
                    :status => {"$last" => "$entitlement_status.status"},
                    :identifier => {"$last" => "$instance_identifier"},
                    :splice_server => {"$last" => "$splice_server"},
                    :systemid => {"$last" => "$facts.systemid"},
                    :hostname => {"$last" => "$name"}
                    }
        },
        {"$sort" => {:status => -1}},

        #RULES MUST COME AFTER THE SORT.  The data will not return correctly if results are limited
        #paginated prior      
        ] + rules)
        logger.info(result.length)
        result

    end
    


    def record
      logger.info(params.to_s)
      checkins = find_instance_checkins(@filter, params)
      render :partial=>'record', :locals=>{:checkins=>checkins}
    end

    def facts
      #debugger
      @record['facts'] = @record['facts'].collect do |f|
        f[0] = f[0].gsub('_dot_', '.')
        #manualyl adjust systemid to not mess up the rendering
        f[0] = 'system.id' if f[0] == 'systemid'
        f
      end

      render :partial=>'facts'
    end

    def products
      #debugger
      @record['product_info'] = @record['product_info'].collect do |p|
        p
      end

      render :partial=>'products'
    end
    
     def checkin
      logger.info("checkin original_id = " + params[:original_id] )
      render :partial=>'checkin', :locals=>{:original_id=>params[:original_id]}
    end

    def checkin_list
      logger.info("checkin_list params: " + params.to_s)
      checkins = find_instance_checkins(@filter, params)
      render :partial=>'checkin_list', :locals=>{:checkins=>checkins}
    end


    def find_filter
      @filter = SpliceReports::Filter.find(params[:filter_id])
    end
    def find_record
      #debugger
      @record = @@c.find({:_id => BSON::ObjectId(params[:id])}).first
    end

    def find_instance_checkins(filter, params)
      #debugger
      result = @@c.find({:_id => BSON::ObjectId(params[:id])},
                :fields => ["_id",
                           "facts.systemid",
                           "entitlement_status.status",
                           "name",
                           "splice_server",
                           "created" ]).as_json
    end

  end 

end
