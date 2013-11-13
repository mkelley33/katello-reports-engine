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
module Navigation
  module RecordMenu
 

    def record_navigation(filter, record)
      menu = [
        { :key => :record_details,
          :name =>_("Subscription Details"),
          :url => lambda{record_splice_reports_filter_reports_path(filter.id, :id=>record['_id'].to_s)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        },
        { :key => :record_facts,
          :name =>_("Facts"),
          :url => lambda{facts_splice_reports_filter_reports_path(filter.id, :id=>record['_id'].to_s)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        },
        { :key => :record_products,
          :name =>_("Products"),
          :url => lambda{products_splice_reports_filter_reports_path(filter.id, :id=>record['_id'].to_s)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        },
        { :key => :record_checkin_list,
          :name =>_("System Check-Ins "),
          :url => lambda{checkin_list_splice_reports_filter_reports_path(filter.id, :id=>record['_id'].to_s)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        }
      ]
      menu
    end


  end
end
end
