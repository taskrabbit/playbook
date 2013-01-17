if defined?(Rails)
  Dir[Rails.root.join('app', 'api', 'controllers', '**', '*_controller.rb')].each{|f| require f }
end

module Playbook
  module Spec
    module RequestHelper

      def self.included(base)
        base.instance_eval do
          let(:headers){ {} }
          let(:interactive_client_app){ stub_object('Client Application', :id => 44, :secret => '428943952jdlksfjo290fudoijsjflks', :key => '290290420954rkdsfduiu29084jfkodsj', :internal => true, :interactive => true, :internal? => true, :interactive? => true)       } # explorer
          let(:internal_client_app){    stub_object('Client Application', :id => 43, :secret => '428943952jdlksfjo290fudoijsjflss', :key => '290290420954rkdsfduiu29084jfkodss', :internal => true, :interactive => false, :internal? => true, :interactive? => false)     } # iphone
          let(:external_client_app){    stub_object('Client Application', :id => 42, :secret => '428943952jdlksfjo290fudoijsjflgg', :key => '290290420954rkdsfduiu29084jfkodgg', :internal => false, :interactive => false, :internal? => false, :interactive? => false)   } # html_other
        
          before :each do 
            reset_api_stubs!
          end
        end
      end

      def get_errors(path, params = {}, headers = {})
        get(path, {}, headers)
        json = JSON.parse(response.body) rescue {}
        json['response'].try(:[], 'errors') || []
      end

      def get_error(path, params = {}, headers = {})
        get_errors(path, params, headers).first
      end 

      def authorize!(client_app)
        if client_app
          headers['X-Client-Application'] = client_app.secret
          request.env['X-Client-Application'] = client_app.secret if defined?(request)
          stub_client_lookup(client_app)
        else
          headers.delete('X-Client-Application')
          request.env.delete('Authorization') if defined?(request)
          stub_client_lookup(nil)
        end
      end

      def authenticate!(user, client_app = nil)
        token = stub_object('Token',
          :user => user,
          :user_id => user.try(:id),
          :client_application => client_app,
          :client_application_id => client_app.try(:id),
          :token => "fake_token",
          :secret => "nekot_ekaf",
          :authorized? => true
        )

        all_controllers.each do |c|
          c.any_instance.send(stub_method, :find_oauth_token_by_key).with(token.token).send(return_method, token)
        end

        headers['Authorization']      = "OAuth #{token.token}"
        request.env['Authorization']  = "OAuth #{token.token}" if defined?(request)
      end

      def authenticate_via_session!(user, app = interactive_client_app)
        all_controllers.each{|c| c.any_instance.send(stub_method, :get_user_id_from_session).send(return_method, user.try(:id)) }
        all_controllers.each{|c| c.any_instance.send(stub_method, :client_token_from_session).send(return_method, app.try(:secret)) }
        stub_client_lookup(app)
      end

      def stub_client_lookup(client)
        all_controllers.each{|c| c.any_instance.send(stub_method, :find_client_application_record).with(client.try(:secret)).send(return_method, client) }
      end

      def get_request_info(path, params = {}, headers = {})
        get path, params, headers
        json = JSON.parse(response.body) rescue {}
        json['request'] || {}
      end

      def stub_method
        Object.respond_to?(:stubs) ? :stubs : :stub
      end

      def return_method
        stub_method == :stubs ? :returns : :and_return
      end

      def all_controllers
        [Playbook::BaseController, Playbook::BaseController.descendants].flatten
      end

      def stub_object(name, atts = {})
        obj = stub_method == :stubs ? stub(name) : double(name)
        atts.each do |k,v|
          obj.send(stub_method, k).send(return_method, v)
        end
        obj
      end

      def reset_api_stubs!
        all_controllers.each do |c|
          [:get_user_id_from_session, :client_token_from_session, :find_client_application_record, :find_oauth_token_by_key].each do |meth|
            c.any_instance.send(stub_method, meth)
            c.any_instance.unstub(meth)
          end
        end
      end
    end
  end
end