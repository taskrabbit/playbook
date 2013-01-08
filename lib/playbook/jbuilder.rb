require 'jbuilder'

module Playbook
  module Jbuilder

    module Jsonp
      extend ActiveSupport::Concern

      included do
        alias_method_chain :target!, :jsonp
      end


      def jsonp!(callback_name)
        @jsonp_callback = callback_name
      end

      def target_with_jsonp!
        json = target_without_jsonp!
        if @jsonp_callback
          "#{@jsonp_callback}(#{json})"
        else
          json
        end
      end

    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :extract!, :api_type
      end

      def collection(col)

        if col.respond_to?(:total_count)
          self.page         col.current_page
          self.total_items  col.total_count
          self.total_pages  col.num_pages
          self.api_type     'PaginatedCollection'
        end

        col = col.all if col.respond_to?(:all)

        self.api_type     'Collection'
        self.item_type    col[0].api_type if col[0].respond_to?(:api_type)

        self.set!(:items) do |j|
          j.array!(col) do |parent, obj|
            yield parent, obj
          end
        end

      end

      def extract_with_api_type!(object, *keys)
        keys = keys | [:api_type] if object.respond_to?(:api_type)
        keys = keys | [:type]     if object.respond_to?(:type)

        extract_without_api_type!(object, *keys)
      end

      def safe_extract!(object, *attributes)
        return extract!(nil) if object.nil?
        extract!(object, *attributes)
      end

      protected

      def _set_value(key, value)
        value = value.to_i if value.is_a?(Date) || value.is_a?(Time)
        super(key, value)
      end
    end
  end
end