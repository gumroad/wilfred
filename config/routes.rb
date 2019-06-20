Wilfred::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get "/logout", to: "devise/sessions#destroy", as: :logout
  end
  get "/onboarding", to: "users#onboarding", as: :onboarding
  get "/repos", to: "users#repos", as: :repos
  post "/repos/pick", to: "users#save_picked_repo", as: :save_picked_repo

  post "/webhook/create", to: "webhooks#github", as: :github_push_webhook
  post "/webhook/deploy_script", to: "webhooks#deploy_script", as: :deploy_webhook

  resources :commits
  post "/commits/:id/remind", to: "commits#remind", as: :remind_commit
  post "/commits/:id/verify", to: "commits#verify", as: :verify_commit
  post "/commits/:id/fail", to: "commits#fail", as: :fail_commit

  post "/commits/verify_from_slack", to: "commits#verify_from_slack", as: :verify_commit_from_slack

  authenticated :user do
    root to: "commits#index", as: :authenticated_root
  end

  scope :api do
    scope "/repos/:repo_id" do
      get "/commits", to: "api/commits#index"
    end
  end

  root to: "public#index"
end
