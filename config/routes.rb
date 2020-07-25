RedmineApp::Application.routes.draw do
  resources :projects do
    member do
      match 'http_integration_settings', :via => [:get, :post]
    end
  end
end
