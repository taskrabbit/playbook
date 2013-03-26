module Playbook
  module ErrorMessageIds

    module ErrorExtender
      def api_id
        @api_id || self.parameterize.gsub('-', '.')
      end

      def api_id=(val)
        @api_id = val
      end
    end

    def self.included(base)
      base.class_eval do
        alias_method_chain :normalize_message, :message_ids
      end
    end

    private

    def normalize_message_with_message_ids(attribute, message, options)
      result = normalize_message_without_message_ids(attribute, message, options)
      result.extend ErrorExtender
      result.api_id = determine_api_id(message, options)
      result
    end

    def determine_api_id(message, options)
      return options[:api_id] if options[:api_id]
      message ||= :invalid
      return message.to_s if message.is_a?(Symbol)
      nil
    end

  end
end