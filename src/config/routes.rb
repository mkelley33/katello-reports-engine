Rails.application.routes.draw do

  namespace :splice_reports do
    resources :filter
    resources :home
  end
end
