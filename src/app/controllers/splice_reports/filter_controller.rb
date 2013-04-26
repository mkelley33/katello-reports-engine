module SpliceReports
  
  class FilterController < ::ApplicationController

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
        }

    end


    def index
      @filters = SpliceReports::Filter.all

      respond_to do |format|
        format.html
        format.json  { render :json => @filters}
      end
    end

  end 

end
