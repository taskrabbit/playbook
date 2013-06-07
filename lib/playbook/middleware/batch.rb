module Playbook
  module Middleware
    module Batch

      def initialize(app)
        @app = app
      end

      def call(env)
        base_request = Rack::Request.new(env)

        if batch_request?(base_request)
          responses = requests(base_request).map do |sub_env|
            @app.call(sub_env)
          end

          finalize(responses)
        else
          @app.call(env)
        end
      end

      protected

      def batch_request?(base_request)
        return false unless Playbook.config.batch_path
        return false unless base_request.post?
        return false unless env['PATH_INFO'] == Playbook.config.batch_path

        true
      end

      def requests(base_request)
        json = decode_json(base_request.body)
        json['requests'].each do |request|
          sub_env = base_request.env.dup

          sub_env.delete_if do |k,v|
            k.to_s =~ /rack\./ && 
            !self.whitelisted_rack_variables.include?(k.to_s)
          end

          q = (request['params'] || {}).to_query

          sub_env.merge!({
            'QUERY_STRING'    => q,
            'PATH_INFO'       => request['path'],
            'REQUEST_METHOD'  => (request['method'] || 'GET').upcase,
            'CONTENT_LENGTH'  => q.length.to_s
          })
        end
      end

      def finalize(responses)
        full_headers = nil
        full_body = []
        responses.each do |status, header, body|
          full_headers ||= header
          full_body << decode_json(body)
        end

        full_body = encode_json(full_body)

        full_headers['Content-Length'] = full_body.length.to_s

        [200, full_headers, full_body]
      end

      def whitelisted_rack_variables
        %w(rack.session rack.session.options rack.logger)
      end

      def decode_json(text)
        ActiveSupport::decode(text)
      end

      def encode_json(json_blob)
        ActiveSupport::encode(json_blob)
      end

    end
  end
end