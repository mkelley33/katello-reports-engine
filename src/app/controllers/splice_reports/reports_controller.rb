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

module SpliceReports
  
  class ReportsController < ::ApplicationController
    @@c = SpliceReports::MongoConn.new.get_coll_marketing_report_data()

    def run_filter_by_id(filter_id, offset)
      filter = SpliceReports::Filter.where(:id=>filter_id).first
      filtered_systems = get_marketing_product_results(filter, offset)
      logger.info(filtered_systems.length)
      logger.info("Splice Reports, id = #{filter_id} filtered_systems: #{filtered_systems.inspect}")
      return filtered_systems
    end

    def get_num_summary(systems)
      num_current = 0
      num_invalid = 0
      num_insufficient = 0
      systems.each do | system | 
        case system["status"]
        when "current"
          num_current += 1
        when "invalid"
          num_invalid += 1
        when "insufficient" 
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
        fields.each { |field| entry << system[field].to_s << ", " }
        entry
      }
      csv_data = "#{header}\n#{body_lines.join("\n")}"
    end

    before_filter :find_record, :only=>[:record, :facts]

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :show => lambda{true},
          :items => lambda{true},
          :record => lambda{true},
          :facts=> lambda{true}
        }

    end

    def show
      filtered_systems = run_filter_by_id(params[:id], nil).as_json
      summary = get_num_summary(filtered_systems)

      #render :partial => "reports/report"
      #render :partial => "report", :locals => {:report_invalid => @report_invalid, :report_valid => @report_valid}
      logger.info("Splice Reports id: #{params[:id]}, num_current = #{summary[:num_current]}, num_invalid = #{summary[:num_invalid]}, num_insufficient = #{summary[:num_insufficient]}")
      render 'show', :locals => {:filter_id => params[:id],  :experimental_ui => true,
                                  :num_current => summary[:num_current], 
                                  :num_invalid => summary[:num_invalid], 
                                  :num_insufficient => summary[:num_insufficient], 
                                  :num_total => summary[:num_total]}
    end

    def items

     respond_to do |format|
        format.csv do
           filtered_systems = self.run_filter_by_id(params[:id], nil)
           render :text => systems_to_csv(filtered_systems.as_json) 
        end
        format.any(:json, :html) do
          filtered_systems = self.run_filter_by_id(params[:id], params[:offset] || 0)
          total = self.run_filter_by_id(params[:id], nil).count
          render :json=>{ :subtotal=>total, :total=>total, :systems=> filtered_systems } 
        end
      end
    end

    def get_marketing_product_results(filter, offset)
      
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

      if filter["status"] == 'all'
        #do nothing
      elsif filter["status"] == 'failed'
        rules << {"$match" =>{ "$or" => [{ :status=> "invalid"}, { :status=> "insufficient"}] } } 
      else
        rules << {"$match" =>  { :status=> filter["status"]}}
      end

      result = @@c.aggregate( [
        {"$match" => {:created=> {"$gt" => start_date, "$lt" => end_date}}},
        {"$group" => {
                    '_id' => "$record_identifier",
                    :date => {"$max" => "$created"},
                    :status => {"$last" => "$status"},
                    :identifier => {"$last" => "$instance_identifier"},
                    :splice_server => {"$last" => "$splice_server"},
                    :systemid => {"$last" => "$systemid"}
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

      render :partial=>'record'

    end

    def facts
      @record['facts'] = @record['facts'].collect do |f|
        f[0] = f[0].gsub('_dot_', '.')
        #manualyl adjust systemid to not mess up the rendering
        f[0] = 'system.id' if f[0] == 'systemid'
        f
      end

      render :partial=>'facts'
    end


    def find_record
      record_id = params[:id]
      @record = @@c.find({"record_identifier" => record_id}).first
    end

    def find_instance_checkins(instance_identifier)
      result4 = @coll.find({"instance_identifier" => instance_identifier}, 
                :fields => ["systemid",
                           "status",
                           "hostname",
                           "environment",
                           "created" ]).as_json
    end



  end 

end
