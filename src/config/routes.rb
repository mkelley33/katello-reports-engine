Rails.application.routes.draw do

  namespace :splice_reports do
    resources :filters do
      collection do
        get :items
      end
    end

    resources :reports do
      member do
        get :items
      end
      collection do
        get :record
        get :facts
      end
    end

  end
end
