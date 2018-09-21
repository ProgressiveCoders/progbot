# frozen_string_literal: true
module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups.
    module Minlength
      def minlength(wrapper_options = nil)
        input_html_options[:minlength] ||= minimum_length_from_validation
        nil
      end

      private

      def minimum_length_from_validation
        minlength = options[:minlength]
        if minlength.is_a?(String) || minlength.is_a?(Integer)
          minlength
        else
          length_validator = find_length_validator
          minimum_length_value_from(length_validator)
        end
      end

      def find_length_validator
        find_validator(:length)
      end

      def has_tokenizer?(length_validator)
        length_validator.options[:tokenizer]
      end

      def minimum_length_value_from(length_validator)
        if length_validator
          length_validator.options[:is] || length_validator.options[:minimum]
        end
      end
    end
  end
end
