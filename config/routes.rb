Rails.application.routes.draw do
  resources :transactions
  get '/byuserid', to: 'transactions#byUserId'
  get '/bydate', to: 'transactions#byDate'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
