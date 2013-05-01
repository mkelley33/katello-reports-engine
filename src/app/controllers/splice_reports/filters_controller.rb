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
  
  class FiltersController < ::ApplicationController

    before_filter :panel_options, :only => [:init_action, :index, :items]


    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
          :items => lambda{true},
          :new => lambda{true},
          :edit => lambda{true},
          :details => lambda{true},
          :update => lambda{true},
          :destroy => lambda{true},
          :create => lambda{true},
          :new => lambda{true},
          :report => lambda{true}
        }

    end


    def index


      respond_to do |format|
        format.html
        format.json  { render :json => @filters}
      end
    end

    def panel_options
      @panel_options = {
          :title => _('Report Filters'),
          :col => ['name'],
          :titles => [_('Name')],
          :create => _('Report Filter'),
          :create_label => _('+ New Filter'),
          :name => controller_display_name,
          :ajax_load => true,
          :ajax_scroll=>items_splice_reports_filters_path(),
          :initial_action => :edit,
          :search_class => Filter,
          :enable_create => true,
          :list_partial => 'splice_reports/filters/list_items'

      }

    end

    def new
      @filter = Filter.new
      render :partial => "new", :locals => {:filter => @filter}
    end

    def create
      params[:splice_reports_filter][:user_id] = current_user.id
      @filter = SpliceReports::Filter.new(params[:splice_reports_filter])

      @filter.save!

      notify.success _("Filter '%s' was created.") % @filter['name']

      if search_validate(SpliceReports::Filter, @filter.id, params[:search])
        #render :partial => "edit", :locals => {:filter => @filter, :editable => current_organization.editable?}
        #notify.message _("'%s' was created successfully.") % @filter["name"]
        render :partial=>"common/list_item", :locals=>{:item=>@filter, :initial_action=>:edit, :accessor=>"id", :columns=>['name'], :name=>controller_display_name}
      else
        notify.message _("'%s' did not meet the current search criteria and is not being shown.") % @filter["name"]
        render :json => { :no_match => true }
      end
    end

    def controller_display_name
      return 'filter'
    end

    def edit
      @filter = SpliceReports::Filter.find(params["id"])
      render :partial => "edit", :locals => {:editable => !@filter.locked}

    end


    def update

      updated_filter = SpliceReports::Filter.find(params[:id])
      result = params[:filter].values.first

      #update attributes

      updated_filter.name = params[:filter][:name] unless params[:filter][:name].nil?

      unless params[:filter][:description].nil?
        result = updated_filter.description = params[:filter][:description].gsub("\n",'')
      end

      updated_filter.status = params[:filter][:status] unless params[:filter][:status].nil?
      updated_filter.satellite_name = params[:filter][:satellite_name] unless params[:filter][:satellite_name].nil?
      updated_filter.hours = params[:filter][:hours] unless params[:filter][:hours].nil?
      updated_filter.start_date = params[:filter][:start_date] unless params[:filter][:start_date].nil?
      updated_filter.end_date = params[:filter][:end_date] unless params[:filter][:end_date].nil?

      updated_filter.save!
      notify.success _("Filter '%s' was updated.") % updated_filter.name

      if not search_validate(Filter, updated_filter.id, params[:search])
        notify.message _("'%s' no longer matches the current search criteria.") % updated_filter["name"]
      end

      render :text => escape_html(result)

    end


    def destroy
      @filter = SpliceReports::Filter.find(params["id"])
      if @filter.destroy
        notify.success _("Filter '%s' was deleted.") % @filter[:name]
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      end
    end

    def items
      ids = Filter.where("user_id = #{current_user.id} or locked = true").pluck(:id)
      render_panel_direct(Filter, @panel_options, params[:search], params[:offset], [:name_sort, 'ask'],
                          {:default_field => :name, :filter=>[{:id=>ids}]})
    end

    def report

      c = SpliceReports::MongoConn.new.get_collection()
      Rails.logger.error(c.find_one)
      @report_invalid = c.find({"status" => "invalid"}).as_json.to_s
      @report_valid = c.find({"status" => "valid"}).as_json.to_s
      filter = SpliceReports::Filter.find(params[:id])
      #render :partial => "reports/report"
      render :partial => "report", :locals => {:report_invalid => @report_invalid, :report_valid => @report_valid}
    end

  end 

end
