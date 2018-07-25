Couchpotatoe::Application.routes.draw do
  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Rails.application.secrets.sidekiq_web_username  \
      && password == Rails.application.secrets.sidekiq_web_password
      
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"

  constraints(ManageConstraint) do
    scope module: 'manage' do
      get 'searches/user_contracts', to: 'searches#user_contracts'

      get '/', to: 'requests#index'

      resources :accounts, only: [:edit, :update] do
        member do
          get :ebics_letter
          get :bill_template
          get :contract_template
        end
      end

      resources :subjects do
        member do
          post :send_message
        end
      end

      resources :billing_cycles do
        member do
          put :all_paid
          get :export_sepa
        end
      end

      resources :billing_items

      resources :calendars do
        collection do
          post :interview_availability
        end
      end

      resources :contracts do
        member do
          get :download
          get :generate_bill
          post :deliver_bill
          post :upload
          get :preview
          post :autosign
          get :autosign, action: :autosign_widget
          post :regenerate
        end

        collection do
          get :move_outs
          get :move_ins
          get :relocations
        end

        resources :receivables do
          member do
            post :refusal
          end
        end
        resources :payments
      end

      resources :rentable_items do
        collection do
          get :bookings
          get :item_type_attributes
        end
        member do
          post :images
          delete :destroy_image
          put :update_image
        end
      end

      resources :container_items

      resources :requests do
        member do
          get :download
          post :verify
        end
      end
    end
  end

  resources :images, only: [:show]
  resources :stylesheets, only: [:show]

  resources :accounts, only: [:create, :new] do
    member do
      get :logo
    end
  end

  resources :contracts do
    member do
      get :download
      get :autosign, action: :autosign_widget
      post :autosign
      get :preview
    end
  end

  get 'admin/featured'

  post 'admin/update_featured'

  resources :requests do
    member do
      get :pay
      post :upload
      get :blank_contract
      get :passport
      get :paypal
      patch :add_billing_item
      patch :delete_billing_item
    end
  end

  get 'users/login_and_registration'

  resources :subjects do
    member do
      post :send_message
    end
  end

  resources :rentable_items do
    member do
      get :gallery
      patch :favorite
    end

    collection do
      get :favorites
    end
  end

  devise_for :users,  :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :passwords => 'users/passwords' }

  resources :users do
    member do
      get :edit_signature
      post :edit_signature, action: :update_signature
    end
  end

  resources :calendars do
    collection do
      post :schedule_interview
    end
  end
  resources :interviews

  get 'landing_pages/welcome'
  get 'landing_pages/imprint'
  get 'landing_pages/faq'
  get 'agb', to: 'landing_pages#terms'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'landing_pages#welcome'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
