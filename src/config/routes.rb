Rails.application.routes.draw do

  namespace :splice_reports do
    resources :filters do
      collection do
        get :items
      end
      resources :reports do
        member do
        end
        collection do
          get :facts
          get :products
          get :record #have to use collection with ?id as get param because of dots
          get :checkin_list
          get :checkin
          get :items
        end
      end
    end

#    resources :reports do
#      member do
#        get :items
#      end
#      collection do
#        get :record
#        get :facts
#      end
#    end

  end
end
