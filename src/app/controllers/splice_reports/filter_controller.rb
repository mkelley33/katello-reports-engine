module SpliceReports
  
  class FilterController < ::ApplicationController

    before_filter :panel_options, :only => [:index, :items]


    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
          :items => lambda{true}
        }

    end


    def index
      @filters = SpliceReports::Filter.all




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
          :ajax_scroll=>items_splice_reports_filter_index_path(),
          :initial_action => :init_action,
          :search_class => Filter,
          :enable_create => true
      }

    end

    def controller_display_name
      return 'filter'
    end

    def init_action
      #@filter = @filters.name
      render :partial => "filter_names", :locals => {:filter => @filter}

    end

    def items
      render_panel_direct(Filter, @panel_options, params[:search], params[:offset], [:name_sort, 'asc'],
                          {:default_field => :name })
    end

  end 

end
