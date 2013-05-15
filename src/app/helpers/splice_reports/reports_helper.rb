module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      #logger.info("HELPER Record:" + record.to_s)
      uuid = record['instance_identifier'].to_s
      System.where(:uuid=>uuid).first
    end

    def get_status(record)
      status = record['entitlement_status']['status']
      if status == "valid"
        color = "green"
      elsif status == "invalid"
        color = "red"
      else
        color = "yellow"
      end
      return color
    end
        

    def system_link(system)
      systems_path() + "#!/?item=#{system.id}&search=id:#{system.id}"
    end

  end
end
