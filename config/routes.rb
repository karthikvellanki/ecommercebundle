Rails.application.routes.draw do
  resources :photos
	scope module: 'api' do
		namespace :v1 do
			resources :products do
				collection do
					get :barcode
				end
			end
			resources :cart_items
			resources :users do
				collection do
					post :login
					get :verify_token
					get :get_user
				end
			end
		end
	end
  resources :supplier_categories
  resources :pages
  resources :quote_requests
  get "live_search", to: "products#live_search"
  get "products/:id/prices", to: "products#price_comparison"

  # Stripe Connect endpoints
  #  - oauth flow
  get '/connect/oauth' => 'stripe#oauth', as: 'stripe_oauth'
  get '/connect/confirm' => 'stripe#confirm', as: 'stripe_confirm'
  get '/connect/deauthorize' => 'stripe#deauthorize', as: 'stripe_deauthorize'

  get "credentials", to: "providers#credentials"
  get "stores", to: "stores#index"
  post "credentials", to: "providers#set_credentials"
  put "credentials", to: "providers#set_credentials"
  delete "credentials/:provider_id", to: "providers#destroy_credentials"
  post "dashboard/request_quotes/create_request_quotes", to: "dashboard/request_quotes#create_request_quotes"
  post "admin/products/products_for_supplier", to: "admin/products#products_for_supplier"

  get "categories", to: "stores#categories"
  get "stores/products", to: "products#index"

  resources :providers
  resources :request_quotes
  resources :banners
  resources :subscriptions
  resources :pictures
  resources :addresses
  resources :cart_items do
		collection do
			post :session_cart_item
		end
  end
  resources :vendors
  resources :manufacturers
  resources :demands
  resources :aggregation_rounds
  resources :categories
  resources :products do
  	collection do
  		get 'get_product_details'
  	end
  end
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  resources :orders do
    collection do
      post 'create_with_default_address'
    end
    member do
      post 'stripe_pay'
      get 'payments'
      post 'process_payment'
      post 'pay'
      post 'pay_with_card'
    end
  end
  get "invoices", :to=> "orders#invoices"
  get "admin/invoices", :to=> "admin/orders#invoices"

  namespace :dashboard do
    resources :inventories, path: "products" do
      collection do
        post 'import'
        delete 'destroy_multiple'
      end
    end
    resources :collections, path: "categories" do
      collection do
        delete 'destroy_multiple'
      end
    end
    resources :users do
      collection do
        post :update_payment
        get :profile
      end
    end
    resources :inventories, path: "products"
    resources :collections, path: "categories"
    resources :providers, path: "suppliers"
    resources :requests, path: "requests"
    resources :request_quotes do
      member do
        post :accept_bid
      end
    end
  end
  # scope :dashboard do
	 #  resources :inventories, path: "products" do
	 #    collection do
	 #      delete 'destroy_multiple'
	 #    end
	 #  end
	 #  resources :collections, path: "categories" do
	 #    collection do
	 #      delete 'destroy_multiple'
	 #    end
	 #  end
	 #  resources :inventories, path: "products"
	 #  resources :collections, path: "categories"
	 #  resources :providers, path: "suppliers"
  #   resources :requests, path: "requests"
  # end
  scope "users/:user_id/" do
    resources :inventories do
      collection do
        get 'byBarcode'
        put 'byBarcode'
        post 'import'
      end
    end
    resources :collections do
      member do
        get 'inventories'
      end
    end
  end
  resources :users do
    collection do
      get 'check_user'
      post 'auth_token'
      get 'authenticated_user_auth_token'
    end
  end
  resources :order_items
  resources :carts do
    member do
      post 'checkout'
      get 'get_cart_items'
      get 'get_small_cart'
    end
  end
  namespace :users do
    resources :addresses
  end
  namespace :admin do
    resources :users do
      collection do
        get :profile
      end
      member do
        get "catalog"
        patch "change_invoice_status"
        post "post_catalog"
      end
    end
    resources :group_products do
    	collection do
      	post 'csv_import'
      end
    end
    resources :customer_groups do
    	collection do
        delete 'destroy_multiple'
      end
    end
    resources :aggregation_rounds
    resources :groups do
    	collection do
        delete 'destroy_multiple'
      end
    end
    resources :demands
    resources :pages do
    	collection do
        delete 'destroy_multiple'
      end
    end
    resources :products do
      member do
        patch 'upload_product_image'
        patch 'change_storefront_option'
      end
      collection do
      	post 'csv_import'
        delete 'destroy_multiple'
      end
    end
    resources :categories
    resources :orders do
      member do
        post 'fulfilled'
      end
    end
    resources :banners
    namespace :providers do
      get "profile"
    end
    resources :providers
    resources :quote_requests
    resources :request_quotes do
      member do
        post "create_bid"
      end
    end
    resources :supplier_categories
  end

  resources :supplier_categories do
  	resources :products, controller: 'supplier_categories/products'
  end
  root to: 'visitors#index'
  namespace :visitors do
    get :contact
    get :payment
    get :index
    get :privacy
    get :terms
  end
  get 'supplier', :to=>"visitors#supplier"
  get 'signup', :to=>"visitors#signup"
  post 'send_message', :to=>"visitors#send_message"
  # get ":provider_id", to: "stores#show"
  get ":provider_id", to: "stores#categories"
  get ":provider_id/products", to: "products#index"
  get "categories/:provider_id/:supplier_category_id", to: "stores#parent_category"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
