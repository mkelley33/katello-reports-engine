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

require 'logging'
require 'time'
require 'date'

module SpliceReports

  class ReportQuery

    def initialize(collection)
      @@c = collection
      logger = Logging.logger(STDOUT)
      logger.level = :info
      logger.info("initialize Report_Query")
    end

  
    def get_marketing_product_results(filter, params, offset, search, page_size)
      logger = Logging.logger(STDOUT)
      logger.level = :info
      logger.info("get_marketing_product_results: filter=#{filter}, offset=#{offset}, search=#{search}")
      logger.info("get_marketing_product_results: organizations=#{filter.organizations}")

      #get org id's
      org_ids = []
      filter.organizations.each do |o|
        org_ids << o.label.to_s
      end
      start_date, end_date = get_start_end_dates(filter)
      logger.info(start_date.to_s)
      logger.info(end_date.to_s)
      rules = []
      rules_inactive_start = []
      rules_inactive_date = []
      rules_active_date = []
      rules_org = []
      rules_status = []
      rules_not_deleted = []
      rules_deleted = []

      if offset
        rules << {"$skip" => offset.to_i}
        rules << {"$limit" => page_size}
      end

      if not search.nil? and not search.blank?
        logger.info("Search by filter id and search term: " + search.to_s )
        rules << {
          "$match" => { 
            "$or" => [
              {"systemid" => {"$regex" => search}},
              {"hostname" => {"$regex" => search}}
            ]
          }
        }
      end

      rules_inactive_start << {"$match" => {:checkin_date=> {"$lt" => end_date}}}
      rules_inactive_date << {"$match" => {:checkin_date=> { "$not" => {"$gt" => start_date}}}}
      rules_active_date << {"$match" => {:checkin_date=> {"$gt" => start_date, "$lt" => end_date}}}
      rules_not_deleted << { "$match" => { "deleted" => { "$exists" => false }}}
      #rules_deleted << {"$match" => { "deleted" => "true"}}
      rules_deleted << { "$match" => { "deleted" => { "$exists" => true }}}

      #move status / state back into an array
      if filter.status.is_a?(String)
        filter.status = filter.status.split(", ")
      end
      if filter.state.is_a?(String)
        filter.state = filter.state.split(", ")
      end

      #translate the terms
      index = filter.status.index("Current") and filter.status[index] = "valid"
      index = filter.status.index("Invalid") and filter.status[index] = "invalid"
      index = filter.status.index("Insufficient") and filter.status[index] = "partial"

      rules_status << {"$match" => { "status" => { "$in" => filter.status }}}
      rules_org << {"$match" => { "organization_id" => { "$in" => org_ids }}}
      
      query = [
        {"$group" => {
                    _id: { ident: "$instance_identifier"},
                    record: {"$last" => "$_id"},
                    checkin_date: {"$max" => "$checkin_date"},
                    status: {"$last" => "$entitlement_status.status"},
                    identifier: {"$last" => "$instance_identifier"},
                    splice_server: {"$last" => "$splice_server"},
                    systemid: {"$last" => "$facts.systemid"},
                    hostname: {"$last" => "$name"},
                    organization_name: {"$last" => "$organization_name"}
                    }
        },
      ]

 
      if params.key?(:sort_by)
        sort_order = Mongo::DESCENDING
        if /DESC/i.match(params[:sort_order])
          sort_order = Mongo::ASCENDING
        end
        #always sort failing at the top
        query.push({"$sort" => {:status => Mongo::DESCENDING}})
        query.push({"$sort" => {params[:sort_by] => sort_order}})
      end

      #"rules" MUST COME AFTER THE SORT.  The data will not return correctly if results are limited
      #paginated prior  
      #The order of rules_org + query + rules_date + rules_status + rules is critical to avoid
      #duplicate entries in the various reports.  
      active_result = []
      inactive_result = []
      deleted_result = []

      if filter.state.include?("Active")
        # find all checkins in org and date range, find the latest checkin per instance_identifier
        active_query = rules_org + rules_active_date +  query + rules_not_deleted + rules_status + rules
        active_result = @@c.aggregate(active_query)
        logger.info("get_marketing_product_results():\nQuery: #{active_query}\nResults #{active_result.count} items")

        #Add / Convert needed data
        active_result.map do |item|
          item["state"] = "active"
          item["status"] = translate_checkin_status(item["status"])
          item
        end
      end
      
      
      if filter.state.include?("Inactive")
        # find the latest checkin per instance in orgs, if checkin is *not* in date range.. it is inactive
        inactive_query = rules_org + rules_inactive_start + query + rules_inactive_date + rules_status + rules_not_deleted + rules

        inactive_result = @@c.aggregate(inactive_query)
        logger.info("get_marketing_product_results():\nQuery: #{inactive_query}\nResults #{inactive_result.count} items")

        inactive_result.map do |item|
          item["state"] = "inactive"
          item["status"] = translate_checkin_status(item["status"])
          item
        end
      end

      if filter.state.include?("Deleted")

        #find any deletion event that occured in the date range
        #deleted_query = rules_org + rules_active_date  + rules_deleted + rules  
        deleted_query = rules_org + rules_active_date + rules_deleted + rules

        deleted_result_unsanitized = @@c.aggregate(deleted_query)
        logger.info("get_marketing_product_results():\nQuery: #{deleted_query}\nResults #{deleted_result.count} items")

        deleted_result_unsanitized.map do |item|
          this_item = @@c.find({"instance_identifier" => item["instance_identifier"]}, {:skip => 0, :limit => 2, :sort => 'checkin_service'}).to_a
          if this_item.count <= 1
            logger.info("Only one record of this instance was found, the found record was a deletion checkin, not enough data to display")
          else
            this_item = this_item[0]
            item["record"] = this_item["_id"]
            item["status"] = "deleted"
            item["splice_server"] = this_item["splice_server"]
            item["systemid"] = this_item["facts"]["systemid"]
            item["hostname"] = this_item["name"]
            item["state"] = "deleted"
            deleted_result << item
          end
        end
      end
 
      result = active_result + inactive_result + deleted_result
      logger.info(result)
      result
      
    end

    def get_start_end_dates(filter)
      if filter.hours != nil
        end_date = Time.now.utc
        num_hours = filter.hours
        start_date = end_date - num_hours.hours
      elsif filter.start_date != nil && filter.end_date != nil
        #for testing
        if filter.start_date.is_a?(String)
          start_date = Date.strptime(filter.start_date, '%Y-%m-%d').to_time
          end_date = Date.strptime(filter.end_date, '%Y-%m-%d').to_time
        else
          start_date = filter.start_date
          end_date = filter.end_date
        end

        end_date = end_date.utc
        start_date = start_date.utc 
      end
      return start_date, end_date
    end

    def translate_checkin_status(value)
      case value
      when "valid"
        "current"
      when "partial"
        "insufficient"
      when "invalid"
        "invalid"
      else
        value
      end
    end

  end
end
