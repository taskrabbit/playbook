module Playbook
  class Engine < Rails::Engine

    initializer 'playbook.play' do |config|
      Playbook.play! :Playbook
    end
    
  end
end