Rails.application.routes.draw do
  root 'bible#index'
  resources :bible, only: [:index, :show]
  
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#index'
      
      resources :books, only: [:index, :show] do
        resources :chapters, only: [:index, :show] do
          resources :verses, only: [:index, :show]
        end
      end
    end
  end
end
