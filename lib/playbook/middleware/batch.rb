module Playbook
  module Middleware
    class Batch

      class UnacceptableRequestError < StandardError
      end

      def initialize(app)
        @app = app
      end

      def call(env)

        return @app.call(env) unless batch_request?(env)

        responses = request_hashes(env).map do |request|
          handle_request(request)
        end

        finalize(responses)

      rescue UnacceptableRequestError
        @app.call(env)
      end

      protected

      def batch_request?(env)
        return false unless Playbook.config.batch_path
        return false unless env['REQUEST_METHOD'] == 'POST'
        return false unless env['PATH_INFO'] == Playbook.config.batch_path

        true
      end

      def request_hashes(env)
        # if they send a bogus (or empty) body we just let the 
        # request through to 404 or whatever the app wants to do
        json = begin
          decode_json(env['rack.input'])
        rescue 
          raise UnacceptableRequestError
        end

        requests  = json.is_a?(Array) ? json : json['requests']

        requests.map do |request|
          sub_env = env.deep_dup

          path    = request['path']
          method  = (request['method'] || 'GET').upcase
          query   = (request['params'] || {}).to_query
          body    = request['body'].to_s

          sub_env['PATH_INFO']      = path
          sub_env['REQUEST_METHOD'] = method
          sub_env['QUERY_STRING']   = query
          sub_env['rack.input']     = StringIO.new(body)

          sub_env
        end
      end

      def handle_request(request)
        status, headers, body = @app.call(request)
        body.close if body.respond_to?(:close)
        
        # rack responses only need to define #each. Some define #join but we can't guarantee it
        # for this reason we implement a join like iterator.
        response_body = ''
        body.each{|bod| response_body << bod }
        response_body
      end

      # decode all the responses then encode as a single response.
      def finalize(responses)

        response = 200
        body     = responses.map{|response| decode_json(response) }.to_json
        headers  = {'Content-Type' => 'application/json'}

        [response, headers, [body]]
      end

      def decode_json(text)
        ActiveSupport::JSON::decode(text)
      end

      def encode_json(json_blob)
        ActiveSupport::JSON::encode(json_blob)
      end

    end
  end
end