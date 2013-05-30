module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      #logger.info("HELPER Record:" + record.to_s)
      uuid = record['instance_identifier'].to_s
      System.where(:uuid=>uuid).first
    end
 
    def get_system_compliance(system)
      compliance = ""
      if system.compliance_color == "green"
        compliance = "Current"
      elsif system.compliance_color == "yellow"
        compliance = "Insufficient" 
      else
        compliance = "Invalid" 
      end
    end

    def get_status_color(record)
      status = record['entitlement_status']['status']
      if status == "current"
        color = "green"
      elsif status == "invalid"
        color = "red"
      else
        color = "yellow"
      end
      return color
    end

    def get_status_message(record)
      status = record['entitlement_status']['status']
      date = record['checkin_date']
      if status == "current"
        message = "Current on " + format_time(date)
      elsif status == "invalid"
        message = "Invalid on " + format_time(date)
      else
        message = "Insuffcient on " + format_time(date)
      end
      return message
    end

    def get_reasons(record)
      reasons = record['entitlement_status']['reasons']
      logger.info("REASONS: " + reasons.to_s)
      return reasons.as_json
    end
        
    def system_link(system)
      systems_path() + "#!/?item=#{system.id}&search=id:#{system.id}"
    end

    def get_filter_details(filter)
      txt =  "<li>Filter Name: #{filter["name"]}</li> 
             <li>Status: #{filter["status"]}</li> "
    end
   
    def get_checkin(system)
      if system.checkin_time
        return  format_time(system.checkin_time)
      end
      _("Never checked in")
    end


  end
end
