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
  
  class ReportsController < ::ApplicationController

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :show => lambda{true},
          :items => lambda{true}
        }

    end

    def show
      @filter = SpliceReports::Filter.find(params[:id])


      #render :partial => "reports/report"
      #render :partial => "report", :locals => {:report_invalid => @report_invalid, :report_valid => @report_valid}
      render 'show'
    end


    def items
      #find the selected filter
      @filter = SpliceReports::Filter.where(:id=>params[:id]).first

      # connect to mongo collection
      c = SpliceReports::MongoConn.new.get_collection()

      #add report criteria
      @report_row = c.find({"status" => @filter[:status]}).as_json
      #debug
      #render :json=>{ :subtotal => 1, :total=>1, :systems=> [c.find_one]  }
      render :json=>{ :subtotal => 1, :total=>1, :systems=> @report_row  }
    end

  end 

end
