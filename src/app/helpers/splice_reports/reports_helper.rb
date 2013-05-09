module SpliceReports
  module ReportsHelper
    include SpliceReports::Navigation::RecordMenu


    def find_system(record)
      uuid = record['instance_identifier']
      System.where(:uuid=>uuid).first
    end

    def system_exists(record)
      !find_system(record).nil?
    end

    def system_link(record)
      system = find_system(record)
      systems_path() + "#!/?item=#{system.id}&search=id:#{system.id}"
    end

  end
end
