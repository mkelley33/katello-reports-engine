#Define a simple query against the splice reports db
require 'logging'
require 'time'

class Query

  def initialize(collection)
  	@@c = collection
  	
  end

  def get_start_end_dates(filter)
  	logger = Logging.logger(STDOUT)
  	logger.level = :info

  	filter = filter.to_hash
	if filter["hours"] != nil
	  end_date = Time.now.utc
	  start_date = end_date - filter["hours"].hours
	elsif filter["start_date"] != nil && filter["end_date"] != nil
      start_date = DateTime.strptime(filter['start_date'], '%Y-%m-%d %l:%M:%S')
      end_date = DateTime.strptime(filter['end_date'], '%Y-%m-%d %l:%M:%S')

      start_date = Time.parse(start_date.to_s).utc
	  end_date = Time.parse(end_date.to_s).utc
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


  def count
  	return @@c.count()
  end

  def get_marketing_product_results(filter, params, offset, search)
      logger = Logging.logger(STDOUT)
  	  logger.level = :info

      logger.info("get_marketing_product_results: filter=#{filter}, offset=#{offset}, search=#{search}")
      logger.info("get_marketing_product_results: organizations=#{filter.organizations}")

      #get org id's
      org_ids = []
      filter.organizations.each do |o|
        org_ids << o.id.to_s
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

      if offset
        rules << {"$skip" => offset.to_i}
        rules << {"$limit" => current_user.page_size}
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

      #move status back into an array
      if filter.status.is_a?(String)
        filter["status"] = filter["status"].split(", ")
      end

      orig_filter = filter
      filter = filter.to_hash

      #translate the terms
      index = filter["status"].index("Current") and filter["status"][index] = "valid"
      index = filter["status"].index("Invalid") and filter["status"][index] = "invalid"
      index = filter["status"].index("Insufficient") and filter["status"][index] = "partial"

      rules_status << {"$match" => { "status" => { "$in" => filter["status"] }}}
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

      if filter["inactive"] == true
        # find the latest checkin per instance in orgs, if checkin is *not* in date range.. it is inactive
        aggregate_query = rules_org + rules_inactive_start + query + rules_inactive_date + rules_status + rules
      else
        # find all checkins in org and date range, find the latest checkin per instance_identifier
        aggregate_query = rules_org + rules_active_date +  query + rules_status + rules
      end

      result = @@c.aggregate(aggregate_query)
      #result = @@c.aggregate( rules_date + query + rules )
      logger.info("get_marketing_product_results():\nQuery: #{aggregate_query}\nResults #{result.count} items")
      #result
      # Translate values in DB to what webui expects
      result.map do |item| 
       item["status"] = translate_checkin_status(item["status"])
       item
      end
    end

end



