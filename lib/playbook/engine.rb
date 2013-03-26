module Playbook
  class Engine < Rails::Engine
    initializer 'playbook.overload_activerecord_errors' do
      ::ActiveModel::Errors.send(:include, ::Playbook::ErrorMessageIds)
    end
  end
end