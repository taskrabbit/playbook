Playbook::Engine.routes.draw do
  get   '/api/:version/test/:controller/:action.:format' if Rails.env.test?
  get   '/api/:version/explorer' => 'playbook/documentation#explorer'
end