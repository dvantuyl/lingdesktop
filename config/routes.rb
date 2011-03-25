Lingdesktop::Application.routes.draw do

  resources :lexicalized_concepts do post 'clone', :on => :member  end

  devise_for :users, :path => 'accounts',
    :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  
  resources :help, :contexts
  
  resources :human_language_varieties do post 'clone', :on => :member  end
  resources :lexical_items do 
    member do
      post 'clone'
      get 'hasProperty'
    end
  end
  
  resources :lexicons do
    resources :lexical_items
    member do
      post 'clone'
    end
  end
  
  resources :groups do get 'members', :on => :member end

  resources :users do
    resources :groups, :only => [:index]
    member do
      get 'followers'
    end
  end
  
  resources :terms do
    member do
      get 'hasMeaning'
      post 'clone'
    end
  end
  
  resources :gold do
    member do
      get 'subclasses', 'individuals'
    end
  end
  
  root :to => "desktop#index"
  
end
