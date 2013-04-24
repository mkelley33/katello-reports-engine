Rails.application.routes.draw do
  namespace :splice_reports do
    resources :filter
  end
end
