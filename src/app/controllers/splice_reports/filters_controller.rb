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
    before_filter :accessible_orgs_hash, :only=>[:new, :edit]
    before_filter :status_hash
    before_filter :avail_splice_servers_hash
    before_filter :number_of_hours_hash
    before_filter :inactive_for_days_hash

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
      read_test = lambda{(current_organization)}
      #not sure if this is correct
        {
          :index => read_test,
          :items => read_test,
          :new => read_test,
          :edit => read_test,
          :details => read_test,
          :update => read_test,
          :destroy => read_test,
          :create => read_test,
          :report => read_test,
          :show => read_test
        }

    end

    def param_rules
      items = {:filter => [:name, :description, :status, :satellite_name, :inactive, :hours, :start_date, :end_date, :organizations]}
      {
        :create => items,
        :update => items
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
      @splice_servers = SpliceReports::MongoConn.new.get_splice_servers()

      render :partial => "new", :locals => {:filter => @filter, :splice_servers => @splice_servers[0]}
    end

    def create
      filter_params = params[:splice_reports_filter]
      filter_params[:user_id] = current_user.id
      org_ids = filter_params[:organizations]
      filter_params[:start_date] = parse_calendar_date(filter_params[:start_date]) unless filter_params[:start_date].blank?
      filter_params[:end_date] = parse_calendar_date(filter_params[:end_date]) unless filter_params[:end_date].blank?
      
      filter_params[:status].delete("") 

      organizations = []
      if org_ids
        logger.info("found orgs")
        #bug in form where an empty value is set
        filter_params[:organizations].delete("") 
        filter_params[:organizations].each do |o|
          if accessible_orgs.where(:id=>o).present?
            org = Organization.find(o)    
            organizations << org
          else
            logger.info("The chosen organization #{o} is not accessible and will not be included in the filter")
          end
        end
      end
      
      #delete the old organization param
      org_ids = filter_params.delete :organizations
      @filter = SpliceReports::Filter.new(filter_params)
      @filter.organizations << organizations
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
      render :partial => "edit", :locals => {:editable => !@filter.locked }

    end


    def update
      @filter = SpliceReports::Filter.find(params[:id])
      filter_params = params[:filter]

      status = filter_params["status"]
      #serialize the array to a string
      #filter_params["status"] = status*","

      if filter_params[:organizations]
         org_ids = filter_params[:organizations]
         @filter.organizations.clear
         @filter.organizations << accessible_orgs.where(:id=>org_ids)
         result = @filter.organizations.collect{|o| o.name}.join(',')
      else
         filter_params[:description] = filter_params[:description].gsub("\n",'') if filter_params[:description]
         result = filter_params.values.first
         filter_params[:start_date] = parse_calendar_date(filter_params[:start_date]) unless filter_params[:start_date].blank?
         filter_params[:end_date] = parse_calendar_date(filter_params[:end_date]) unless filter_params[:end_date].blank?
         
      end

      @filter.update_attributes(filter_params) 
      @filter.save!
      notify.success _("Filter '%s' was updated.") % @filter.name

      if not search_validate(Filter, @filter.id, params[:search])
        notify.message _("'%s' no longer matches the current search criteria.") % @filter["name"]
      end

      render :text => escape_html(result)

    end


    def show
      @filter = SpliceReports::Filter.find(params[:id])
      render :partial=>"common/list_update", :locals=>{:item=>@filter, :accessor=>"id", :columns=>['name']}
    end

    def destroy
      @filter = SpliceReports::Filter.find(params["id"])
      if @filter.destroy
        notify.success _("Filter '%s' was deleted.") % @filter[:name]
        render :partial => "common/list_remove", :locals => {:id=>params[:id], :name=>controller_display_name}
      end
    end

    def accessible_orgs_hash
      @accessible_orgs_hash = Hash[*accessible_orgs.map{ |p| [p.id, p.name] }.flatten]
    end

    def avail_splice_servers
      @splice_servers = SpliceReports::MongoConn.new.get_splice_servers()
    end

    def status_hash
      status = ["Current", "Invalid", "Insufficient"]
      status_hash = {}
      status.each_with_index { |val, index|
        status_hash[val] = val
      }
      @status_hash =  status_hash
    end

    def avail_splice_servers_hash
      splice_servers = SpliceReports::MongoConn.new.get_splice_servers()
      server_hash = {}
      splice_servers.each_with_index { |val, index|
        server_hash[val] = val
      }
      @available_splice_servers_hash =  server_hash
    end

    def number_of_hours_hash
      hours = [nil, 4, 8, 24, 48]
      num_hash = {}
      hours.each_with_index { |val, index|
        num_hash[val] = val
      }
      @number_of_hours_hash = num_hash
    end

    def inactive_for_days_hash
      days = [nil, 1, 3, 10, 30]
      days_hash = {}
      days.each_with_index { |val, index|
        days_hash[val] = val
      }
      @inactive_for_days_hash = days_hash
    end

    def accessible_orgs
      Organization.readable
    end

    def items
      ids = Filter.where("user_id = #{current_user.id} or locked = true").pluck(:id)
      render_panel_direct(Filter, @panel_options, params[:search], params[:offset], [:name_sort, 'ask'],
                          {:default_field => :name, :filter=>[{:id=>ids}]})
    end


  end 

end
