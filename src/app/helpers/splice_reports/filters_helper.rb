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

  module FiltersHelper
    def friendly_date(date_obj)
      return nil if date_obj.nil?
      date_obj.strftime('%m/%d/%Y')
    end

    def tip_status
      tip = _("Search for check-ins based on the Subscription Status of the system")
    end

    def tip_org
      tip = _("List of Organizations that the user has access to. Pick one or more Organizations")
    end

    def tip_time_text
    	tip = _("Find check-in's that have occurred in the specified time frame.  You may search for 
          check-ins from the last 4 to 48 hours, or you may specify a range of dates")
    end

    def tip_lifecycle_state
    	tip = _("Active is defined as a system that is sending check-ins to the Satellite Server.  Inactive
        is defined as a registered system that has no check-ins in the specified time period.  Deleted 
        is defined as a system that has been removed from the Satellite")
    end
  end

end