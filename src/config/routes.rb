Rails.application.routes.draw do

  namespace :splice_reports do
    resources :filters do
      collection do
        get :items
      end
    end
    resources :home
  end
end
