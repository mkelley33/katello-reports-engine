module SpliceReports
  
  class FilterController < ::ApplicationController

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true}
        }

    end

    def filter

    end

    def index
      render :text => 'HELLOOOOO'
    end

  end 

end
