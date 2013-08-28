module Playbook
  module ErrorMessageIds
    extend ActiveSupport::Concern

    module ErrorExtender
      def api_id
        @api_id || self.parameterize.gsub('-', '_')
      end

      def api_id=(val)
        @api_id = val
      end
    end

    included do
      alias_method_chain :normalize_message, :message_ids
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