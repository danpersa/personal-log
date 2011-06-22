PersonalLog::Application.routes.draw do

  resources :users do
    member do
      get :following, :followers, :ideas
    end
    resource :profile, :only => [:edit, :create, :update],
             :path_names => {:edit => ''},
             :as => :profile
  end

  resources :sessions, :only => [:new, :create, :destroy]
  
  resources :ideas, :only => [:show, :create, :update, :destroy] do
    member do
      # the list of users that shares the idea
      get :users
    end
  end

  resources :idea_lists, :only => [:index, :show, :new, :create, :edit, :update, :destroy],
            :path => 'idea-lists'
  
  resources :reminders, :only => [:index, :create, :destroy]
  resources :relationships, :only => [:create, :destroy]
  resources :reset_passwords,
            :path => 'reset-password',
            :only => [:new, :create],
            # the new path is the same as the create path
            :path_names => {:new => ''}
            
  resources :change_reseted_passwords,
            :path => 'change-reseted-password',
            :only => [:edit, :create],
            # the edit path is the same as the create path
            :path_names => {:edit => ''}
            
  resources :change_passwords,
            :path => 'change-password',
            :only => [:new, :create],
            # the new path is the same as the create path
            :path_names => {:new => ''}
      
  root                                  :to => 'pages#home'
  match '/signup',                      :to => 'users#new'
  match '/activate',                    :to => 'users#activate'
  
  #match '/change-reseted-password',            :to => 'users#change_reseted_password',
  #                                     :as => 'change_reseted_password'
                                        
  
  #match '/change-reseted-password/:password_reset_code',   
  #                                      :to => 'users#change_reseted_password',
  #                                      :constraints => {:password_reset_code => /[A-Za-z0-9]+/},
  #                                      :via => :get
  
  #match '/change-reseted-password',             :to => 'errors#routing',
  #                                      :via => 'get'
  
  match '/signin',                      :to => 'sessions#new'
  match '/signout',                     :to => 'sessions#destroy'

  match '/contact',                     :to => 'pages#contact'
  match '/about',                       :to => 'pages#about'
  match '/help',                        :to => 'pages#help'
  match '/reset-password-mail-sent',    :to => 'pages#reset_password_mail_sent'
  
  match '/remind-me-too/:idea_id',      :to => 'reminders#remind_me_too',
                                        :constraints => { :idea_id => /[0-9]+/ },
                                        :as => 'remind_me_too'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
