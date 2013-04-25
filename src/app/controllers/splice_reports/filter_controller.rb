module SpliceReports
  
  class FilterController < ::ApplicationController

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
        }

    end


    def index

    end

  end 

end
