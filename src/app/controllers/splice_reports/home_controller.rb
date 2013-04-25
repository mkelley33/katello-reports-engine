module SpliceReports

  class HomeController < ApplicationController
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
