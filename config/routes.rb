Rails.application.routes.draw do
  resources :transactions
  get '/by_user_id', to: 'transactions#byUserId'
  get '/by_date', to: 'transactions#byDate'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
