module SpliceReports
  
  class FilterController < ::ApplicationController

    def rules
      read_system = lambda{System.find(params[:id]).readable?}
        {
          :index => lambda{true},
          :filter => lambda{true}
        }

    end

    def list

    end


    def index
      #render :text => 'HELLOOOOO'
      render :list
    end


  end 

end
