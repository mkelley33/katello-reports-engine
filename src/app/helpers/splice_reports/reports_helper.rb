module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      #logger.info("HELPER Record:" + record.to_s)
      uuid = record['instance_identifier'].to_s
      System.where(:uuid=>uuid).first
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
      if status == "current"
        message = "Subscriptions are Current"
      elsif status == "invalid"
        message = "Subscriptions are not Current"
      else
        message = "Subscriptions are Insuffcient"
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

  end
end
