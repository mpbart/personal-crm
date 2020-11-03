Rails.application.routes.draw do
  devise_for :users, controllers: {
                      sessions:      'users/sessions',
                      registrations: 'users/registrations'}

  # Home Page
  root 'home#index'

  # Plaid
  post '/get_access_token', to: 'plaid#get_access_token'
  post '/refresh_accounts', to: 'plaid#refresh_accounts'
  post '/create_link_token', to: 'plaid#create_link_token'

  # Transactions
  resources :transactions, only: [:index, :show, :update]
  resources :split_transactions, only: [:index]
  post '/split_transaction', to: 'transactions#split_transaction'

  # Analytics
  get 'analytics',    to: 'analytics#index'

  # Budgets
  get 'budgets',      to: 'budgets#index'
end
