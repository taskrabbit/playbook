Playbook::Engine.routes.draw do
  match '/api/:version/test/:controller/:action.:format' if Rails.env.test?
  get   '/api/:version/explorer' => 'playbook/documentation#explorer'
end