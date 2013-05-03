module SpliceReports

  module FiltersHelper
    def friendly_date(date_obj)
      return nil if date_obj.nil?
      date_obj.strftime('%m/%d/%Y')
    end

  end

end