Playbook::Engine.routes.draw do
  get   '/api/:version/test/:controller/:action.:format' if Rails.env.test?
end