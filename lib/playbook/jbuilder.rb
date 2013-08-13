require 'jbuilder'

module Playbook
  module Jbuilder

    module TemplateExtensions
      
      def collection!(col, options = {})

        if cache_options = options.delete(:cache)
          cache_key = cache_key_for_collection(cache_options.delete(:key), col)
          self.cache! cache_key, cache_options do
            self.extract_collection!(col, options)
          end
        else
          self.extract_collection!(col, options)
        end

      end

      protected

      def cache_key_for_collection(base_key, col)
        key = [base_key]
        if col.respond_to?(:current_page)
          key << "page"
          key << col.current_page
        end
        key.flatten.reject(&:blank?).join('-')
      end

    end

    module Extensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :extract!, :api_type
        alias_method_chain :_set_value, :time_formatting
      end


      def extract_collection!(col, options = {})


        partial = options[:partial]
        as      = options[:as]

        self.api_type     'Collection'

        if col.respond_to?(:total_count)
          self.page         col.current_page
          self.total_items  col.total_count
          self.total_pages  col.num_pages
          self.api_type     'PaginatedCollection'
        end

        col = col.to_a if col.respond_to?(:to_a) && !(col.respond_to?(:loaded?) && col.loaded?)
        
        self.item_type    col[0].api_type if col[0].respond_to?(:api_type)

        self.set!(:items) do
          self.array!(col) do |obj|
            if partial
              self.partial! partial, as => obj
            else
              yield parent, obj
            end
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

      def _set_value_with_time_formatting(key, value)
        if value.is_a?(Date)
          value = value.to_time.to_i
        elsif value.is_a?(Time)
          value = value.to_i
        end

        _set_value_without_time_formatting(key, value)
      end
    end
  end
end