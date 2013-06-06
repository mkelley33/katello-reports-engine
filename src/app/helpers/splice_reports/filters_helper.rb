module SpliceReports

  module FiltersHelper
    def friendly_date(date_obj)
      return nil if date_obj.nil?
      date_obj.strftime('%m/%d/%Y')
    end

    def tip_time_text
    	tip = _("Find check-in's that have occurred in the specified time frame.  You may search for 
          check-ins from the last 4 to 48 hours, or you may specify a range of dates")
    end

    def tip_inactive_text
    	tip = _("Find systems that have not checked-in during the specified time frame.")
    end
  end

end