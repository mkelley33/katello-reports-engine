module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      #logger.info("HELPER Record:" + record.to_s)
      uuid = record['_id'].to_s
      System.where(:uuid=>uuid).first
    end

    def system_link(system)
      systems_path() + "#!/?item=#{system.id}&search=id:#{system.id}"
    end

  end
end
